import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringSerializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Properties;

public class ProducerDemoCallback {

    public static void main(String[] args) {
        final Logger logger = LoggerFactory.getLogger(ProducerDemoCallback.class);

        String bootstrapServers = Config.bootstrapServers;
        String topic = Config.topic;

        // set up Producer properties
        Properties properties = new Properties();
        properties.setProperty(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        properties.setProperty(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        properties.setProperty(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        // create the producer
        KafkaProducer<String, String> producer = new KafkaProducer<>(properties);

        // send the message - asynchronous
        for (int i = 0; i < 5; i++) {
            // produce a message
            String value = "Kafka 101 " + i;

            ProducerRecord<String, String> record =
                    new ProducerRecord<>(topic, value);

            producer.send(record, new Callback() {
                public void onCompletion(RecordMetadata recordMetadata, Exception ex) {
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
                }
            });
        }

        // flush and close producer
        producer.flush();
        producer.close();
    }

}
