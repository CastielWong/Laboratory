import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.serialization.StringSerializer;

import java.util.Properties;

public class ProducerDemo {

    public static void main(String[] args) {
        String bootstrapServers = Config.bootstrapServers;
        String topic = Config.topic;

        // set up Producer properties
        Properties properties = new Properties();
        properties.setProperty(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        properties.setProperty(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        properties.setProperty(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        // create the producer
        KafkaProducer<String, String> producer;
        producer = new KafkaProducer<String, String>(properties);

        // produce a message
        ProducerRecord<String, String> record =
                new ProducerRecord<>(topic, "Kafka 101");

        // send the message - asynchronous
        producer.send(record);

        // flush and close producer
        producer.flush();
        producer.close();
    }

}
