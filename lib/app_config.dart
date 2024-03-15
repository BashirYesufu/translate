
enum Environment { SANDBOX, LIVE }

class BaseUrl {
  static Map<String, dynamic>?  _config;
  static Environment? _env;

  static void setEnvironment(Environment env) {
    _env = env;
    switch (env) {
      case Environment.SANDBOX:
        _config = _BaseUrlConfig.sandboxConstants;
        break;
      case Environment.LIVE:
        _config = _BaseUrlConfig.liveConstants;
        break;
    }
  }

  static Environment? getEnvironment() {
    return _env;
  }

  static get BASE_URL {
    return _config?[_BaseUrlConfig.BASE_URL];
  }

}

class _BaseUrlConfig{
  static const BASE_URL = 'BaseUrl';

  static Map<String, dynamic> sandboxConstants = {
    BASE_URL: "",
  };

  static Map<String, dynamic> liveConstants = {
    BASE_URL: "",
  };
}