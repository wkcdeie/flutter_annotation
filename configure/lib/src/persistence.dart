abstract class ConfigurePersistence {
  void put(String key, dynamic value);

  dynamic get(String key);

  dynamic remove(String key);

  void clear();
}
