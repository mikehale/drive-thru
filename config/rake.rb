COMPANY_NAME = "Example Com"
ZONE_NAME = "example.com."
ZONE_IP = "a.b.c.d"
API_PASSWORD = "" # from manage.slicehost.com
NEW_COOKBOOK_LICENSE = :apachev2

HOST = ZONE_IP
HOST_LOGIN="root@#{HOST}"
RSYNC="rsync -avz --delete --delete-excluded --exclude '.*'"
TOPDIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))
