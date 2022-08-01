#! /bin/bash
# ssh ubuntu@staging-docker 'sudo git clone git@github.com:museumofthefuture/motf.website.docker.git /opt/code/motf.website.docker'
# ssh ubuntu@staging-docker 'git clone git@github.com:museumofthefuture/motf.website.docker.git /opt/code/motf.website.docker'
# ssh ubuntu@staging-docker 'sudo git -C /opt/code/motf.website.docker  pull || sudo git clone  git@github.com:museumofthefuture/motf.website.docker.git /opt/code/motf.website.docker'

branch=$1
dir="/opt/code"
srcdir="/opt/code/motf.website.docker/src"
workingdirectory="/opt/code/"
webdirectory="/opt/code/motf.website.docker"
firstime=0
changed=0

 updatewebsite () {

    cd $webdirectory 

    if [[ $firsttime = 1 ]]; then
            echo "Docker not running .... skippng"
    else
            echo "Stopping Docker If Already Running "
	            docker-compose down
    fi

    echo "Downloding Latest Environment File"
        envfile="env.${branch_name}"
        aws --region me-south-1 s3 cp s3://motf-misc/$envfile .
        mv $envfile .env

    echo "Run and Build Website"
    	cd $webdirectory 
        docker-compose up -d --build site
	
    echo "Prepare the website build" 
	docker-compose run --rm npm ci --only=production
	docker-compose run --rm npm run production

    echo "Install Reuqired Packages"
	docker-compose run --rm composer install --prefer-dist --no-scripts --no-dev --optimize-autoloader --no-ansi

    echo "Run NPM" 
	docker-compose run --rm npm ci --only=production


    echo "Install Laravel and Predis"
    	cd $webdirectory 
        docker-compose run --rm composer require laravel/envoy --dev
        docker-compose run --rm composer require predis/predis

    echo "Install Reuqired Packages"
    	cd $webdirectory 
        docker-compose run --rm composer install --prefer-dist --no-scripts --no-dev -o
        docker-compose run --rm composer update barryvdh/laravel-debugbar

    echo "Assets Generate "
    	cd $webdirectory 
        docker-compose run --rm npm ci --only=production


    echo "Clearining Running Artisan For Website"
    	cd $webdirectory 
        docker-compose run --rm artisan config:clear
        docker-compose run --rm  artisan cache:clear
        docker-compose run --rm artisan route:clear
        docker-compose run --rm artisan view:clear
        docker-compose run --rm artisan cache:invalidate-cloudfront

    echo "Creating Cache"
    	cd $webdirectory 
        docker-compose run --rm artisan config:cache
        docker-compose run --rm artisan route:cache
        docker-compose run --rm artisan view:cache

    echo "Updating Twill"
        #docker-compose run --rm artisan twill:update


    echo "Copying Horizon Assets"
    	cd $webdirectory 
        docker-compose run --rm artisan horizon:publish
}


if [[ ! -d $dir ]]; then
    sudo git clone git@github.com:museumofthefuture/motf.website.docker.git /opt/code/motf.website.docker
elif [[ -d $dir ]]; then
    echo "$dir already exists but is not a directory" 1>&2
    cd /opt/code/motf.website.docker
    git pull
fi

cd $workingdirectory/motf.website.docker/

if [[ ! -d $srcdir ]]; then
    echo "Checking Out Website Code Branch $branch"
	git clone -b $branch git@github.com:museumofthefuture/motf.website.twill.git src
    firstime=1

elif [[ -d $srcdir ]]; then
    echo "$dir/src already exists" 1>&2
fi

echo "Checking Existing Branch Name"
    cd $workingdirectory/motf.website.docker/src
    branch_name=`git symbolic-ref --short -q HEAD`
    echo $branch_name

if [[ $branch_name == $branch ]]; then
    changed=0
            git remote update && git status -uno | grep -q 'Your branch is behind' && changed=1
                if [ $changed = 1 ]; then
                        git pull
                        echo "Updated successfully";
                        update=1
                else
                        echo "Up-to-date"
                        update=0
                fi
fi

echo "update is $update"
echo "firstime is $firstime"


if [[ $changed == 1 ]]; then

    updatewebsite

elif [[ $changed == 0 && $firstime == 1 ]]; then

    updatewebsite

else

    echo "Nothing Updated In Code So Skipping Build Process"

fi
