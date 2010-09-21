if abiquo_installed?

include AETK::OutputFormatters

def vbox_installed?
  RPMUtils.rpm_installed? 'vboxmanage'
end

two_cols "VBoxManage:".bold, vbox_installed? ? 'Installed'.green.bold : 'Not found'.yellow.bold

end
