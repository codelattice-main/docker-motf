
# About Website

The website is built on OPENSOURC tool Twill which is a  Laravel package that helps developers rapidly create a custom CMS that is beautiful, powerful, and flexible. By standardizing common functions without compromising developer control, Twill makes it easy to deliver a feature-rich admin console that focuses on modern publishing needs.


# Benefits overview

With a vast number of pre-built features and custom-built Vue.js UI components, developers can focus their efforts on the unique aspects of their applications instead of rebuilding standard ones. 

Built to get out of your way, Twill offers:
* No lock-in, create your data models or hook existing ones
* No front-end assumptions, use it within your Laravel app or headless
* No bloat, turn off features you don’t need
* No need to write/adapt HTML for the admin UI
* No limits, extend as you see fit


# Components 

The main part of brining the website up is the docker-compose.yml file located in the root folder 

Other Directories Descriptions are 
* Nginx to have a local NGINX Running 
* php holding the twill website CMS 
* redis to spawn a local redis server 



# Environment 
In order to get the wesbite running the most important part is to have a env variable file stored in the PHP folder 
Within the Environment variable files we define the properties of the website 
### Application
* APP_NAME="Museum of the Future"
* APP_ENV=testing
* APP_KEY=base64:
* APP_DEBUG=false
* APP_ORIGIN_DOMAIN=testing-origin.museumofthefuture.ae
* APP_DOMAIN=museumofthefuture.ae
* APP_SUBDOMAIN=testingg
* APP_URL=http://${APP_SUBDOMAIN}.${APP_DOMAIN}
* APP_LATITUDE=25.2048493
* APP_LONGITUDE=55.2707828
* APP_ADDRESS="Sheikh Zayed Rd - Trade Centre - Dubai"


# Create API Key 
To Create an API Key Use the following command to generate 

```
cd <website directory> 
artisan key:generate
```


# To Run the Website 
```
docker-compose build 
docker-compose up -d 
```

# TO Run It Locally Without AWS 
* Make sure you have access to RDS Staging Environment 
* Make sure you have IAM Configured on your machine 
* SSL Is Required to be terminated on NGINX 
* Access to Cloudfront is Required


