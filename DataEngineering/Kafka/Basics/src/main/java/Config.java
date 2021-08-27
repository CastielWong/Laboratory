
public class Config {
    public static String bootstrapServers = "127.0.0.1:9092";
    // check if such topic exists before producing or consuming
    public static String topic = "demo-topic";
    public static String groupId = "demo-group";
    public static String resetMode = "earliest";

    public Config() {
    }
}
