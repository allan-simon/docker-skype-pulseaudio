# docker command
export DOCKER_CMD	= sudo docker

# name of the docker image to be built
export DOCKER_IMAGE	= allan-skype

# temporary directory to store the ssh key and pulseaudio cookie
export TMP		= tmp

export TMP_KEY		= $(TMP)/id_rsa
export TMP_COOKIE	= $(TMP)/pulse-cookie



all: build home

# build the docker image
build: .stamp-build
.stamp-build: Dockerfile
	$(DOCKER_CMD) build -t '$(DOCKER_IMAGE)' --build-arg TIMEZONE=$(cat /etc/timezone) .
	touch '$@'

# prepare the container home directory + the ssh key
home: .stamp-home
.stamp-home:
	mkdir -p $(TMP)
	chmod 0700 $(TMP)
	ssh-keygen -f '$(TMP_KEY)' -N ''
	touch '$@'

# run skype
run: all
	cp ~/.config/pulse/cookie $(TMP_COOKIE)
	chmod og+r $(TMP_COOKIE)
	bash launch.sh


clean:
	rm -f '$(TMP_KEY)' '$(TMP_KEY).pub' '$(TMP_COOKIE)' .stamp-*
	rmdir '$(TMP)' || true

