#!/usr/bin/env sh

WATCH="${HUGO_WATCH:=false}"
SLEEP="${HUGO_REFRESH_TIME:=-1}"
echo "HUGO_WATCH:" $WATCH
echo "HUGO_REFRESH_TIME:" $HUGO_REFRESH_TIME
echo "HUGO_THEME:" $HUGO_THEME
echo "HUGO_BASEURL" $HUGO_BASEURL

HUGO=/usr/bin/hugo

#hugo new site wesleyhales && cd wesleyhales && \
#cd wesleyhales && git clone https://github.com/allnightgrocery/hugo-theme-blueberry-detox.git themes/detox


while [ true ]
do
    if [[ $HUGO_WATCH != 'false' ]]; then
	    echo "Watching..."
	    #--appendPort="false"
	      rm -rf /output/* && \
        $HUGO server --watch=true --source="/src/wesleyhales" --theme="$HUGO_THEME" --destination="/output" --baseUrl="$HUGO_BASEURL" --bind="0.0.0.0" || exit 1
    else
	    echo "Building one time..."
	      rm -rf /output/* && \
        $HUGO --source="/src/wesleyhales" --theme="$HUGO_THEME" --destination="/output" --baseUrl="$HUGO_BASEURL" || exit 1
    fi

    if [[ $HUGO_REFRESH_TIME == -1 ]]; then
        exit 0
    fi
    echo "Sleeping for $HUGO_REFRESH_TIME seconds..."
    sleep $SLEEP
done