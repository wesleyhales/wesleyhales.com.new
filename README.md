docker build . -t wesleyhales
docker run -ti -p 1313:1313 -v $(pwd)/output:/output -v $(pwd)/wesleyhales:/src/wesleyhales -e "HUGO_BASEURL=http://localhost:1313" -e "HUGO_APPEND_PORT=true" -e "HUGO_THEME=detox" -e "HUGO_WATCH=true" wesleyhales
docker exec -ti wesleyhales /bin/ash

### __PROD SETTINGS
docker run -ti -p 1313:1313 -v $(pwd)/output:/output -v $(pwd)/wesleyhales:/src/wesleyhales -e "HUGO_BASEURL=wesleyhales.com" -e "HUGO_APPEND_PORT=false" -e "HUGO_THEME=detox" -e "HUGO_WATCH=true" wesleyhales
"HUGO_BASEURL=www.wesleyhales.com"
"HUGO_APPEND_PORT=false"
