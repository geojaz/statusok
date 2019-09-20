#!/bin/bash

set -ex
export DEVTOOLS_DIR="${HOME}/dev"

# the gcloud functions were borrowed from https://github.com/Khan/khan-dotfiles/blob/master/setup.sh
install_and_setup_gcloud() {
    version=263.0.0  
    if ! which gcloud >/dev/null; then
        echo "Installing Google Cloud SDK (gcloud)"
        # On mac, we could alternately do `brew install google-cloud-sdk`,
        # but we need this code for linux anyway, so we might as well be
        # consistent across platforms; this also makes dotfiles simpler.
        platform="$(uname -s | tr ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz)-$(uname -m)"
        gcloud_url="https://storage.googleapis.com/cloud-sdk-release/google-cloud-sdk-$version-$platform.tar.gz"
        local_archive_filename="/tmp/gcloud-$version.tar.gz"
        curl "$gcloud_url" >"$local_archive_filename"
        (
            cd "$DEVTOOLS_DIR"
            rm -rf google-cloud-sdk  # just in case an old one is hanging out
            tar -xzf "$local_archive_filename"
        )
        PATH="$DEVTOOLS_DIR/google-cloud-sdk/bin:$PATH"
    fi

    if [ -z "$(gcloud auth list --format='value(account)')" ]; then
        echo "You'll now need to log in to gcloud.  This will open a browser;"
        echo "log in and/or select your GCP account, and click allow."
        gcloud auth login
        gcloud auth application-default login
    fi

    echo "Ensuring gcloud is up to date and has the right components."
    gcloud components update --quiet --version="$version"
    gcloud components install --quiet kubectl gsutil
    
    # app-engine-java app-engine-python \
    #     bq cloud-datastore-emulator gsutil pubsub-emulator beta

    gcloud config set component_manager/disable_update_check true
}


install_and_setup_gcloud
