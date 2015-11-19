== Geocam Space Development Environment Setup Procedure ==

0. Install Virtualbox (version 4.3.10)

1. Install the latest version of vagrant:
http://www.vagrantup.com/downloads

2. Do {{{ git clone https://babelfish.arc.nasa.gov/git/georef_deploy/ }}}

3. Go inside the georef_deploy folder, and run the "setup_site_vagrant.sh" script. The script should initialize the vagrant box and it clones all the submodules that are needed.

4. Do {{{ vagrant ssh }}} from georef_deploy dir.

5.  And get new packages
 {{{ sudo apt-get install libjpeg-dev zlib1g-dev libpng12-dev }}}

6. download PIL {{{ sudo pip install PIL --allow-external PIL --allow-unverified PIL }}}

7. Run {{{ ./manage.py bootstrap --yes }}}. If any of the packages are missing at this point, do a "sudo pip install [package name]".

Do {{{ source sourceme.sh }}}

9. Do {{{ ./manage.py syncdb }}} to set up the databases. When it asks for a username and pwd, set it to "vagrant" for both.

10. Do {{{ ./manage.py prep }}} 

11. Switch PIL to pillow

Do {{{ sudo pip uninstall PIL }}}

Do {{{ sudo apt-get install libjpeg-dev zlib1g-dev libpng12-dev}}}

Do {{{ sudo pip install pillow }}}

11. Run "./manage.py runserver 0.0.0.0:8000", which should get the development server running. Leave this running.

12. Open up a Chrome browser, and go to "http://[vagrant IP address]:8000 " to access GeoRef.
