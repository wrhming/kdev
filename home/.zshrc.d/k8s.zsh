if (( $+commands[kubectl] )); then
    source $CFG/.zshrc.d/k8s/kubectl.zsh
    source $CFG/.zshrc.d/k8s/kube-ps1.zsh

    export KUBE_EDITOR=vim

    if (( $+commands[k3d] )); then
        export KUBECONFIG="$(k3d get-kubeconfig --name='k3s-default')"
    elif (( $+commands[k3s] )); then
        export KUBECONFIG=~/.local/etc/rancher/k3s/k3s.yaml
        # sudo k3s server --docker --no-deploy traefik
    fi

    if [[ ! "$PATH" == */opt/cni/bin* && -d /opt/cni/bin ]]; then
        export PATH=/opt/cni/bin:$PATH
    fi

fi
