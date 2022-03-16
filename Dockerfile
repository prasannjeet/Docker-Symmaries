FROM ubuntu:20.04

ENV OPAM_VERSION    2.1.2
ENV OCAML_VERSION   4.07.0
ENV HOME            /home/opam
ENV TZ              Europe/Stockholm
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y sudo patch unzip curl make gcc libx11-dev xz-utils && \
    \
    adduser --disabled-password --home $HOME --shell /bin/bash --gecos '' opam && \
    \
    echo 'opam ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers && \
    curl -L -o /usr/bin/opam "https://github.com/ocaml/opam/releases/download/$OPAM_VERSION/opam-$OPAM_VERSION-$(uname -m)-$(uname -s)" && \
    chmod 755 /usr/bin/opam && \
    su opam -c "opam init -a -y --comp $OCAML_VERSION" && \
    \
    find $HOME/.opam -regex '.*\.\(cmt\|cmti\|annot\|byte\)' -delete && \
    rm -rf $HOME/.opam/archives \
           $HOME/.opam/repo/default/compilers \
           $HOME/.opam/repo/default/packages \
           $HOME/.opam/repo/default/archives \
           $HOME/.opam/$OCAML_VERSION/man \
           $HOME/.opam/$OCAML_VERSION/build && \
    \
    apt-get autoremove -y && \
    apt-get autoclean

RUN apt-get install -y m4 pkg-config libgmp-dev libmpfr-dev build-essential && \
    opam repo add nberth-devel https://framagit.org/nberth/opam-repo/raw/devel && \
    opam repository add nberth-devel --all-switches && \
    opam update && \
    opam install symmaries -y --assume-depexts

USER opam
WORKDIR $HOME/output
ENTRYPOINT [ "opam", "config", "exec", "--" ]
CMD [ "bash" ]