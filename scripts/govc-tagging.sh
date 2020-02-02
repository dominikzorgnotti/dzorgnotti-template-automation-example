# Get get datacenter from the build manifest
VM_DATACENTER=$(cat packer-build-manifest/packer-manifest.json | jq ".builds[]| .custom_data | .vcenter_datacenter") 
# Strip the "" from the output
VM_DATACENTER=${VM_DATACENTER//\"/}
# Read the name of the VM from the build manifest
VM_NAME=$(cat packer-build-manifest/packer-manifest.json | jq ".builds[]| .artifact_id")
VM_NAME=${VM_NAME//\"/}
# Build the path to the VM from the two pre-filled variables
VM_PATH="/$VM_DATACENTER/vm/$VM_NAME"
CATEGORY=""
# Iterate through os_family, os_release, deployment_flavor, deployment_release to create vCenter tag categories prefixed with tpl_
# Then assign tags based on the actual build values from the manifest to the VM
for CATEGORY in os_family os_release deployment_flavor deployment_release
do 
  TAG=""
  if govc tags.category.info tpl_$CATEGORY >/dev/null 2>&1
  then
    echo "Category tpl_$CATEGORY already exists"
  else
    echo "Category tpl_$CATEGORY created"
    govc tags.category.create -t VirtualMachine tpl_$CATEGORY
  fi
  TAG=$(cat packer-build-manifest/packer-manifest.json | jq ".builds[]| .custom_data | .$CATEGORY")
  TAG=${TAG//\"/}
  if govc tags.info $TAG >/dev/null 2>&1
  then
    echo "Tag $TAG already exists"
  else
    echo "Tag $TAG in category tpl_$CATEGORY created"
    govc tags.create -c tpl_$CATEGORY $TAG
  fi
  echo "Attaching tag $TAG to VM $VM_NAME"
  govc tags.attach -c tpl_$CATEGORY $TAG $VM_PATH
done
