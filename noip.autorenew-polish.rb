#!/usr/bin/env ruby

# Summary:	The script avoid the need to manualy login every month in http://www.noip.com and update your domains to keep them alive.
#			It will automaticaly retrieve his current public IP from http://checkip.dyndns.org/
# Author: Felipe Molina (@felmoltor)
# Date: July 2013
# License: GPLv3
# updated & translate to Polish language: @tomciu 
# Changes  02.08.2016:
# - replace http://checkip.dyndns.org to https://api.ipify.org (is faster, thx @LukeOwncloud for tip in perl version)
# - update & translate log/errors messages
# - change user agent to 'Windows Mozilla'

require 'date'
require 'mechanize'
require 'net/http'

def getMyCurrentIP()
	m = Mechanize.new
	m.user_agent_alias = 'Windows Mozilla'
	
ip = Net::HTTP.get(URI("https://api.ipify.org"))
	return ip
end

# ================

def setMyCurrentNoIP(user,password,my_public_ip)
	
	updated_hosts = []
	
	m = Mechanize.new
	m.user_agent_alias = 'Windows Mozilla'
	
	loginpage = m.get("https://www.noip.com/login/")
	
	members_page = loginpage.form_with(:id => 'clogs') do |form|
		form.username = user
		form.password = password
	end.submit
	
	# Once successfuly loged in, access to DNS manage page
	dns_page = m.get("https://www.noip.com/members/dns/")
	dns_page.links_with(:text => "Modify").each do |link|
		# Update all the domains with my current IP
		update_host_page = m.click(link)
		hostname = update_host_page.forms[0].field_with(:name => "host[host]").value
		domain = update_host_page.forms[0].field_with(:name => "host[domain]").value
		updated_hosts << "#{hostname}.#{domain}"
		update_host_page.forms[0].field_with(:name => "host[ip]").value = my_public_ip
		update_host_page.forms[0].submit
	end
	
	return updated_hosts
end

# ================

puts "======== Start zadania: #{Date.today.to_s} #{Time.now.strftime "%T"} ========================\n\n"

if ARGV[0].nil? or ARGV[1].nil?
# 	puts "Error. Enter your username and password to access your account noip.com"
	puts "Błąd!!! Podaj swoją nazwę użytkownika i hasło do serwisu noip.com\n"
	puts "w formacie: noip.autorenew.rb użytkownik hasło"
puts "\n======== Koniec zadania: #{Date.today.to_s} #{Time.now.strftime "%T"} =======================\n\n"

	exit(1)
else
	user = ARGV[0]
	password = ARGV[1]	
	# domain_to_update = ARGV[3] if !ARGV[3].nil? # TODO: If you want to keep alive only one domain, specify it
	
#	puts "Getting my current public IP..."
	puts "Pobieranie aktualnego adresu IP..."
	my_public_ip = getMyCurrentIP()
#	puts "Done: #{my_public_ip}"
#	puts "Sending Keep Alive request to noip.com..."
	puts "Zrobione...\nTwój adres IP to: #{my_public_ip}"
	puts "Trwa odnawianie domen zarejestrowanych w noip.com..."
	updated_hosts = setMyCurrentNoIP(user,password,my_public_ip)	
	if !updated_hosts.nil? and updated_hosts.size > 0
#		puts "Done. Keeping alive #{updated_hosts.size} host with IP '#{my_public_ip}':"
		puts "Zrobione...\nOdnowiono #{updated_hosts.size} poniższą(e) domenę(y) używając adresu IP '#{my_public_ip}':"
		updated_hosts.each do |host|
			puts "- #{host}"
		end
	else
#		$stderr.puts "There was an error updating the domains of noip.com or there were no hosts to update"
		$stderr.puts "Błąd!!! Prawdobodobnie nie ma domen do aktualizacji\nlub nazwa użytkownika i hasło są nieprawidłowe. Sprawdź to!!!"
	end
end
puts "\n======== Koniec zadania: #{Date.today.to_s} #{Time.now.strftime "%T"} =======================\n\n"
