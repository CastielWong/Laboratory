import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.errors.WakeupException;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.Duration;
import java.util.Arrays;
import java.util.Properties;
import java.util.concurrent.CountDownLatch;

public class ConsumerDemoWithThread {

    private ConsumerDemoWithThread() {
    }

    private void run() {
        Logger logger = LoggerFactory.getLogger(ConsumerDemoWithThread.class.getName());

        String bootstrapServers = Config.bootstrapServers;
        String topic = Config.topic;
        String groupId = Config.groupId;

        CountDownLatch latch = new CountDownLatch(1);

        logger.info("Creating the consumer thread");
        Runnable consumerRunnable = new ConsumerRunnable(
                bootstrapServers,
                groupId,
                topic,
                latch
        );

        Thread thread = new Thread(consumerRunnable);
        thread.start();

        // add a shutdown hook
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            logger.info("Caught shutdown hook");
            ((ConsumerRunnable) consumerRunnable).shutdown();

            try {
                latch.await();
            } catch (InterruptedException ex) {
                ex.printStackTrace();
            }
            logger.info("Application has exited.");
        }
        ));

        try {
            latch.await();
        } catch (InterruptedException ex) {
            logger.error("Application got interrupted", ex);
        } finally {
            logger.info("Application is closing.");
        }
    }

    public static void main(String[] args) {
        new ConsumerDemoWithThread().run();
    }


    public class ConsumerRunnable implements Runnable {
        private CountDownLatch latch;
        private KafkaConsumer<String, String> consumer;
        private Logger logger = LoggerFactory.getLogger(ConsumerRunnable.class.getName());

        public ConsumerRunnable(
                String bootstrapServers,
                String groupId,
                String topic,
                CountDownLatch latch) {
            this.latch = latch;

            String resetMode = "earliest";

            // set up Consumer properties
            Properties properties = new Properties();
            properties.setProperty(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
            properties.setProperty(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
            properties.setProperty(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
            properties.setProperty(ConsumerConfig.GROUP_ID_CONFIG, groupId);
            properties.setProperty(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, resetMode);

            // create the consumer
            this.consumer = new KafkaConsumer<>(properties);
            // subscribe consumer to topic(s)
            this.consumer.subscribe(Arrays.asList(topic));
        }

        @Override
        public void run() {
            // poll for new messages
            try {
                while (true) {
                    ConsumerRecords<String, String> records = this.consumer.poll(Duration.ofMillis(100));

                    for (ConsumerRecord<String, String> record : records) {
                        logger.info(String.format(
                                "Key: %s, Value: %s"
                                , record.key()
                                , record.value())
                        );
                        logger.info(String.format(
                                "Partition: %s, Offset: %s"
                                , record.partition()
                                , record.offset())
                        );

                    }
                }
            } catch (WakeupException ex) {
                logger.info("Received shutdown signal.");
            } finally {
                this.consumer.close();
                this.latch.countDown();
            }
        }

        public void shutdown() {
            // wakeup() method will throw the exception WakeUpException
            this.consumer.wakeup();
        }
    }

}
