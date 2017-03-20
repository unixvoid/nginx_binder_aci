OS_PERMS=sudo
NGINX_BIN=https://cryo.unixvoid.com/bin/nginx/fancy_index/nginx-1.11.10-linux-amd64

all:	build_aci

prep_aci:
	cp -R deps/nginx-layout .
	# pull nginx binary
	wget -O nginx-layout/rootfs/bin/nginx $(NGINX_BIN)
	chmod +x nginx-layout/rootfs/bin/nginx
	# move in configs
	mkdir -p nginx-layout/rootfs/nginx/conf/
	cp deps/nginx.conf nginx-layout/rootfs/nginx/conf/
	cp deps/mime.types nginx-layout/rootfs/nginx/conf/
	cp deps/manifest.json nginx-layout/manifest

build_aci:	prep_aci
	actool build nginx-layout nginx-binder.aci
	@echo "nginx-binder.aci built"

build_travis_aci: prep_aci
	wget https://github.com/appc/spec/releases/download/v0.8.7/appc-v0.8.7.tar.gz
	tar -zxf appc-v0.8.7.tar.gz
	# build image
	appc-v0.8.7/actool build nginx-layout nginx-binder.aci
	rm -rf appc-v0.8.7*
	@echo "nginx-binder.aci built"

test:
	$(OS_PERMS) rkt run ./nginx-binder.aci --insecure-options=image --net=host

clean:
	rm -rf nginx-layout
	rm -f nginx-binder.aci
	rm -f nginx-binder.aci.asc
