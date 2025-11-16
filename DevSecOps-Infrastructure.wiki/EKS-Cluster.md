# Amazon EKS Cluster Guide

The Kubernetes cluster is created using the official Terraform EKS module.

## Configure kubeconfig

After `terraform apply`, export the kubeconfig:

```bash
terraform output secure_shop_eks_kubeconfig > kubeconfig_secure_shop
export KUBECONFIG=$PWD/kubeconfig_secure_shop
```

## Validate the Cluster

```bash
kubectl get nodes
```

Expected result: worker nodes are in the **Ready** state.

## Useful Commands

```bash
kubectl get pods -A
kubectl get svc
kubectl describe node <node-name>
```
