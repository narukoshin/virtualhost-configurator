<h1>😖 Apache2 and Nginx Virtual Host Configurator</h1>
<div>
    <a target="_blank" href="https://twitter.com/narukoshin"><img src="https://media4.giphy.com/media/iFUiSYMNPvIJZDpMKN/giphy.gif?cid=ecf05e471v5jn6vuhczu1tflu2wm7qt11atwybfwcgaqxz38&rid=giphy.gif&ct=s" align="middle" width="120"></a>
    <a target="_blank" href="https://instagram.com/naru.koshin"><img src="https://media1.giphy.com/media/Wu9Graz2W46frtHFKc/giphy.gif?cid=ecf05e47h46mbuhq40rgevni5rbxgadpw5icrr71vr9nu8d4&rid=giphy.gif&ct=s" align="middle" width="120"></a>
    <a target="_blank" href="https://tryhackme.com/p/narukoshin"><img align="middle" src="https://www.secjuice.com/content/images/2019/01/TryHackMe-logo---small.png" width="120"></a>
  </div>

<h1>🤯  About the script</h1>
<p>Are you already tired from writing Apache2 or nginx configuration manually? I found a solution for that by writing a script where you just answer on some questions about your virtual host and script will do everything for you.</p?>
<p>Before you start your new experience with virtual host configuration, you need to install apache2, if you want to use nginx, you need to install it too.</p>

```bash
# to install the script from the repository
# type the command below, if you are already familiar with git and how it works, then you can ignore this message.:P
git clone https://github.com/narukoshin/virtualhost-configurator

# Enter the directory that you just now cloned
cd virtualhost-configurator

# grant execute access to the script
chmod +x virtualhost-configurator.sh

# now, run it as root because it will work with services configuration files so it requires a root access
sudo ./virtualhost-configurator.sh

# script will ask you a few questions about your virtual host and create configuration...
# ...and folders depending on your answers so make sure, that you type everything correctly.

Before we begin setting up the apache2 virtual host, we need you to specify the name of conf
Please type the name of conf: (eg. narukoshin.me): mywebsite.com

# and so on...
# If you choose to create Virtual Host with SSL, you need to add them first before you restart your service(-s).
# I hope you know how to do that.
# Later, when you finished your configuration, you successfuly set your SSL certificates in place, you can now reload services.
# To restart the services use commands below

# For apache2
sudo systemctl restart apache2 
# or
sudo service apache2 restart

# for nginx
sudo systemctl restart nginx
# or
sudo service nginx restart
```
