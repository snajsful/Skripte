#!/bin/sh
echo "kako ce da se zove baza"
read baza
echo Ime korisnika :
read korisnik
echo password za korisnika:
read password
echo izabrali ste ime baze : $baza
sleep 2
sudo mysql -e "create database $baza;"
echo Kreirana je baza;
sudo mysql -e "create user '$korisnik'@'localhost' identified by '$password';"
sudo mysql -e "grant all on $baza.* to '$korisnik'@'localhost';"
sudo mysql -e "flush privileges;"

