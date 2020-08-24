import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringSerializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Properties;
import java.util.concurrent.ExecutionException;

public class ProducerDemoWithKey {

    public static void main(String[] args) {
        final Logger logger = LoggerFactory.getLogger(ProducerDemoWithKey.class);

        String bootstrapServers = Config.bootstrapServers;
        String topic = Config.topic;

        // set up Producer properties
        Properties properties = new Properties();
        properties.setProperty(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        properties.setProperty(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        properties.setProperty(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        // create the producer
        KafkaProducer<String, String> producer = new KafkaProducer<String, String>(properties);

        // send the message - asynchronous
        for (int i = 0; i < 5; i++) {
            // produce a message
            String value = "Kafka 101 " + i;
            String key = "id_" + i;

            logger.info("Key: " + key);

            ProducerRecord<String, String> record =
                    new ProducerRecord<>(topic, key, value);

            // block the send() us get() to make it synchronous (message send in tandem)
            // so that key in logging would come with the rest together
            try {
                producer.send(record, (recordMetadata, ex) -> {
                    // executes whenever a record is successfully sent or an exception is thrown
                    if (ex == null) {
                        logger.info(
                                String.format("Received new metadata. \n" +
                                        "Topic: %s\n" +
                                        "Partition: %d\n" +
                                        "Offset: %s\n" +
                                        "Timestamp: %s"
                                        , recordMetadata.topic()
                                        , recordMetadata.partition()
                                        , recordMetadata.offset()
                                        , recordMetadata.timestamp()
                                )
                        );
                    } else {
                        logger.error("Error while producing message: ", ex);
                    }
                }).get();
            } catch (InterruptedException | ExecutionException e) {
                e.printStackTrace();
            }
        }

        // flush and close producer
        producer.flush();
        producer.close();
    }

}
