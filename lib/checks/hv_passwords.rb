
if abiquo_installed?

include AETK
include AETK::OutputFormatters

def hvpasswd_match?
  vf_cfg = abiquo_virtualfactory_config
  vsm_cfg  = abiquo_vsm_config
  nc_cfg = abiquo_nodecollector_config
  #check libvirt 
  vsm_pwd = config_property(vsm_cfg, 'hypervisors/libvirtAgent/password')
  nc_pwd = config_property(nc_cfg, 'wsman/password')
  vf_pwd = config_property(vf_cfg, 'rimp/password')
  if (vsm_pwd != nc_pwd) or (vsm_pwd != vf_pwd) or (nc_pwd != vf_pwd)
    return false
  end
  
  #check vmware
  vsm_pwd = config_property(vsm_cfg, 'hypervisors/vmware/password')
  nc_pwd = config_property(nc_cfg, 'hypervisors/esxi/password')
  vf_pwd = config_property(vf_cfg, 'hypervisors/vmware/password')
  if (vsm_pwd != nc_pwd) or (vsm_pwd != vf_pwd) or (nc_pwd != vf_pwd)
    return false
  end
  #check hyperv
  vsm_pwd = config_property(vsm_cfg, 'hypervisors/hyperv/password')
  nc_pwd = config_property(nc_cfg, 'hypervisors/hyperv/password')
  vf_pwd = config_property(vf_cfg, 'hypervisors/hyperv/password')
  if (vsm_pwd != nc_pwd) or (vsm_pwd != vf_pwd) or (nc_pwd != vf_pwd)
    return false
  end
  #check xenserver
  vsm_pwd = config_property(vsm_cfg, 'hypervisors/xenserver/password')
  nc_pwd = config_property(nc_cfg, 'hypervisors/xenserver/password')
  vf_pwd = config_property(vf_cfg, 'hypervisors/xenserver/password')
  if (vsm_pwd != nc_pwd) or (vsm_pwd != vf_pwd) or (nc_pwd != vf_pwd)
    return false
  end
  true
end

if (detect_install_type == :monolithic) or (detect_install_type == :remote_services)
  if hvpasswd_match?
    two_cols("Hypervisor Passwords:".bold, "Match".bold.green)
  else
    two_cols("Hypervisor Passwords:".bold, "Do not match".red.bold)
  end
end
           
end
