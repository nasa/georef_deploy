# These settings are appended to the template found in
# <site>/management/templates/settings.py. They customize the setup for
# a vagrant VM environment.

from siteSettings import *  # pylint: disable=W0401

# Make this unique, and don't share it with anybody.  Used by Django's
# cookie-based authentication mechanism.
#SECRET_KEY = 'f4-_mq%p-ipi^x)z*wcon%#ci#50(a1t&amp;+n@smwr)hx3_fg#-t'
USING_APP_ENGINE = False

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
