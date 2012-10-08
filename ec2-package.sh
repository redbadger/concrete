mkdir -p chef
vagrant status > /dev/null
tar czf chef/cookbooks.tgz --files-from chef/run_list 2> /dev/null
rm chef/run_list
echo "Done."
echo "Upload the contents of /chef to the server with the following command:"
echo "scp -i KEY_FILE -r chef USER_NAME@HOST_NAME:/tmp/"
echo "SSH into the server and run the following:"
echo "cd /tmp/chef"
echo "sudo bash ./install.sh"