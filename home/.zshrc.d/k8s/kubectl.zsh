if (( $+commands[kubectl] )); then
    __KUBECTL_COMPLETION_FILE="${HOME}/.zsh_cache/kubectl_completion"

    if [[ ! -f $__KUBECTL_COMPLETION_FILE ]]; then
        mkdir -p ${HOME}/.zsh_cache
        kubectl completion zsh >! $__KUBECTL_COMPLETION_FILE
    fi

    [[ -f $__KUBECTL_COMPLETION_FILE ]] && source $__KUBECTL_COMPLETION_FILE

    unset __KUBECTL_COMPLETION_FILE
fi

# This command is used a LOT both below and in daily life
alias k=kubectl
alias kg='kubectl get'
alias ko='kubectl get -o yaml'
alias kd='kubectl describe'
alias ke='kubectl edit'
alias kc='kubectl create'
alias klb="kubectl label --overwrite"

# Execute a kubectl command against all namespaces
alias kca='_kca(){ kubectl "$@" --all-namespaces;  unset -f _kca; }; _kca'

# Apply a YML file
alias kaf='kubectl apply -f'
# Apply resources from a directory containing kustomization.yaml
alias kak='kubectl apply -k'

# Drop into an interactive terminal on a container
alias keti='kubectl exec -ti'
alias ka='kubectl exec -ti'

# Manage configuration quickly to switch contexts between local, dev ad staging.
alias kcuc='kubectl config use-context'
alias kcsc='kubectl config set-context'
alias kcdc='kubectl config delete-context'
alias kccc='kubectl config current-context'

# List all contexts
alias kcgc='kubectl config get-contexts'

# General aliases
alias kdel='kubectl delete'
alias kdelf='kubectl delete -f'
alias kdelk='kubectl delete -k'

# Pod management.
alias kgp='kubectl get pods'
alias kop='kubectl get -o yaml pods'
alias kgpa='kubectl get pods --all-namespaces'
alias kgpw='kgp --watch'
alias kgpwide='kgp -o wide'
alias kep='kubectl edit pods'
alias kdp='kubectl describe pods'
alias kdelp='kubectl delete pods'

# get pod by label: kgpl "app=myapp" -n myns
alias kgpl='kgp -l'

# get pod by namespace: kgpn kube-system"
alias kgpn='kgp -n'

# Service management.
alias kgs='kubectl get svc'
alias kos='kubectl get -o yaml svc'
alias kgsa='kubectl get svc --all-namespaces'
alias kgsw='kgs --watch'
alias kgswide='kgs -o wide'
alias kes='kubectl edit svc'
alias kds='kubectl describe svc'
alias kdels='kubectl delete svc'

# Ingress management
alias kgi='kubectl get ingress'
alias koi='kubectl get -o yaml ingress'
alias kgia='kubectl get ingress --all-namespaces'
alias kei='kubectl edit ingress'
alias kdi='kubectl describe ingress'
alias kdeli='kubectl delete ingress'

# Namespace management
alias kgns='kubectl get namespaces'
alias kgnsl='kgns -o jsonpath="{.items[*].metadata.name}" -l'
alias kons='kubectl get -o yaml namespaces'
alias kens='kubectl edit namespace'
alias kdns='kubectl describe namespace'
alias kcns='kubectl create namespace'
alias klbns="klb namespace"
alias kdelns='kubectl delete namespace'
alias kcn='kubectl config set-context $(kubectl config current-context) --namespace'

# ConfigMap management
alias kgcm='kubectl get configmaps'
alias kocm='kubectl get -o yaml configmaps'
alias kgcma='kubectl get configmaps --all-namespaces'
alias kecm='kubectl edit configmap'
alias kdcm='kubectl describe configmap'
alias kdelcm='kubectl delete configmap'

# Secret management
alias kgsec='kubectl get secret'
alias kosec='kubectl get -o yaml secret'
alias kgseca='kubectl get secret --all-namespaces'
alias kdsec='kubectl describe secret'
alias kdelsec='kubectl delete secret'

# Deployment management.
alias kgd='kubectl get deployment'
alias kod='kubectl get -o yaml deployment'
alias kgda='kubectl get deployment --all-namespaces'
alias kgdw='kgd --watch'
alias kgdwide='kgd -o wide'
alias ked='kubectl edit deployment'
alias kdd='kubectl describe deployment'
alias kdeld='kubectl delete deployment'
alias ksd='kubectl scale deployment'
alias krsd='kubectl rollout status deployment'
kres(){
    kubectl set env $@ REFRESHED_AT=$(date +%Y%m%d%H%M%S)
}

# Rollout management.
alias kgrs='kubectl get rs'
alias krh='kubectl rollout history'
alias kru='kubectl rollout undo'

# Statefulset management.
alias kgss='kubectl get statefulset'
alias koss='kubectl get -o yaml statefulset'
alias kgssa='kubectl get statefulset --all-namespaces'
alias kgssw='kgss --watch'
alias kgsswide='kgss -o wide'
alias kess='kubectl edit statefulset'
alias kdss='kubectl describe statefulset'
alias kdelss='kubectl delete statefulset'
alias ksss='kubectl scale statefulset'
alias krsss='kubectl rollout status statefulset'

# Port forwarding
alias kpf='kubectl port-forward'

# Tools for accessing all information
alias kga='kubectl get all'
alias kgaa='kubectl get all --all-namespaces'

# Logs
alias kl='kubectl logs'
alias kl1h='kubectl logs --since 1h'
alias kl1m='kubectl logs --since 1m'
alias kl1s='kubectl logs --since 1s'
alias klf='kubectl logs -f'
alias klf1h='kubectl logs --since 1h -f'
alias klf1m='kubectl logs --since 1m -f'
alias klf1s='kubectl logs --since 1s -f'

# File copy
alias kcp='kubectl cp'

# Node Management
alias kgno='kubectl get nodes'
alias keno='kubectl edit node'
alias kdno='kubectl describe node'
alias kdelno='kubectl delete node'

# PVC management.
alias kgpv='kubectl get pv'
alias kgpvc='kubectl get pvc'
alias kgpvca='kubectl get pvc --all-namespaces'
alias kgpvcw='kgpvc --watch'
alias kepvc='kubectl edit pvc'
alias kdpvc='kubectl describe pvc'
alias kdelpvc='kubectl delete pvc'

# top
alias ktn='kubectl top node'
alias ktp='kubectl top pod'

### kcc
function kcc {
    export KUBECONFIG=~/.kube/$1
    #_kube_ps1_update_cache
}

_kcc() {
    local -a contexts
    local desc
    if (( $+commands[yq] )); then
        desc='yq r $i 'current-context''
    else
        desc='$i'
    fi
    for i in $(ls ~/.kube/*config*); do
        contexts+="$(basename ${i}):$(eval $desc)"
    done
    _describe 'contexts' contexts
}

compdef _kcc kcc

###
function clean-evicted-pod {
    kubectl get pods --all-namespaces -ojson \
        | jq -r '.items[] | select(.status.reason!=null) | select(.status.reason | contains("Evicted")) | .metadata.name + " " + .metadata.namespace' \
        | xargs -n2 -l bash -c "kubectl delete pods \$0 --namespace=\$1"
}

function rm-stucked-ns {
    kubectl get namespace "$1" -o json \
        | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" \
        | kubectl replace --raw /api/v1/namespaces/$1/finalize -f -
}

### helm
if (( $+commands[helm] )); then
    __HELM_COMPLETION_FILE="${HOME}/.zsh_cache/helm_completion"

    if [[ ! -f $__HELM_COMPLETION_FILE ]]; then
        helm completion zsh >! $__HELM_COMPLETION_FILE
    fi

    [[ -f $__HELM_COMPLETION_FILE ]] && source $__HELM_COMPLETION_FILE

    unset __HELM_COMPLETION_FILE
fi
