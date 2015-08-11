class Specinfra::Command::Freebsd::Base::Interface < Specinfra::Command::Base::Interface 
  class << self
    def check_exists(name)
      "ifconfig #{name}"
    end

    def check_has_ipv4_address(interface, ip_address)
      ip_address = ip_address.dup
      if ip_address =~ /\/\d+$/
        # remove the prefix - better would be to calculate the netmask
        ip_address.gsub!(/\/\d+$/, "") 
      end
      ip_address << " "
      ip_address.gsub!(".", "\\.")
      "ifconfig #{interface} inet | grep 'inet #{ip_address}'"
    end

    def check_has_ipv6_address(interface, ip_address)
      ip_address = ip_address.dup
      (ip_address, prefixlen) = ip_address.split(/\//)
      ip_address.downcase!
      if ip_address =~ /^fe80::/i
        # link local needs the scope (interface) appended 
        ip_address << "%#{interface}"
      end 
      unless prefixlen.to_s.empty? 
        # append prefixlen 
        ip_address << " prefixlen #{prefixlen}"
      else 
        ip_address << " "
      end
      "ifconfig #{interface} inet6 | grep 'inet6 #{ip_address}'"
    end

    def get_link_state(interface)
      str = %Q{ ifconfig #{interface} link | \
            awk '/flags/{ \
                   split($0,line,/ /) ; \
                   split(line[2],flags,/[,<>]/); \
                   for (idx in flags) { \
                     if (flags[idx] == "UP"){ \
                       print "up"; \
                       exit 0 ; \
                     } \
                   }; \
                   print "down"; \
                 }'}
      str
    end
  end
end
