PROD_ENV = 'prod'
STAGING_ENV = 'staging'
TEST_ENV = 'test'


class LoginEnvAwareManager(object):

    def __init__(self, login_manager_prod, login_manager_test, login_manager_staging=None):
        self.login_manager = login_manager_prod
        self.login_manager_test = login_manager_test
        self.login_manager_staging = login_manager_staging

    def check_login_status(self, resp, current_env=PROD_ENV):
        self._get_login_manger_by_env(current_env).check_login_status(resp)

    def get_cookies(self, current_env=PROD_ENV):
        return self._get_login_manger_by_env(current_env).get_cookies()

    def _get_login_manger_by_env(self, env):
        if env == PROD_ENV:
            return self.login_manager
        elif env == TEST_ENV:
            return self.login_manager_test
        elif env == STAGING_ENV:
            return self.login_manager_staging

    def get_url(self, relative_path, env=PROD_ENV):
        if relative_path.startswith('http'):
            return relative_path
        return self._get_login_manger_by_env(env).login_url + relative_path;
