# These settings are appended to the template found in
# <site>/management/templates/settings.py. They customize the setup for
# a vagrant VM environment.

DATABASES = {
    'default': {
        'ENGINE': 'django.contrib.gis.db.backends.mysql',
        'NAME': 'georef',
        'USER': 'vagrant',
        'PASSWORD': 'vagrant',
        'HOST': '127.0.0.1',
        'PORT': '3306',
    }
}

SERVER_ROOT_URL = 'http://10.0.3.18/'

GEOCAM_UTIL_SECURITY_ENABLED = False
