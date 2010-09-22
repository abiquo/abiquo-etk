# Generated from abiquo-etk-0.3.gem by gem2rpm -*- rpm-spec -*-
%define ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%define gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%define gemname abiquo-etk
%define geminstdir %{gemdir}/gems/%{gemname}-%{version}

Summary: Abiquo Elite Toolkit
Name: rubygem-%{gemname}
Version: 0.3.8
Release: 1%{?dist}
Group: Development/Languages
License: GPLv2+ or Ruby
URL: http://github.com/rubiojr/abiquo-etk
Source0: %{gemname}-%{version}.gem
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires: rubygems
BuildRequires: rubygems
BuildArch: noarch
Provides: rubygem(%{gemname}) = %{version}

%description
Tools to troubleshoot your Abiquo installation


%prep

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{gemdir}
gem install --local --install-dir %{buildroot}%{gemdir} \
            --force --rdoc %{SOURCE0}
mkdir -p %{buildroot}/%{_bindir}
mv %{buildroot}%{gemdir}/bin/* %{buildroot}/%{_bindir}
rmdir %{buildroot}%{gemdir}/bin
find %{buildroot}%{geminstdir}/bin -type f | xargs chmod a+x

%clean
rm -rf %{buildroot}

%files
%defattr(-, root, root, -)
%{_bindir}/abicli
%{_bindir}/aetk-setup-server
%{_bindir}/aetk-setup-rs
%{_bindir}/aetk-setup-v2v
%{_bindir}/abiquo-check-16-install
%{gemdir}/gems/%{gemname}-%{version}/
%doc %{gemdir}/doc/%{gemname}-%{version}
%doc %{geminstdir}/LICENSE
%doc %{geminstdir}/README.rdoc
%doc %{geminstdir}/TODO
%{gemdir}/cache/%{gemname}-%{version}.gem
%{gemdir}/specifications/%{gemname}-%{version}.gemspec


%changelog
* Wed Sep 22 2010 : Sergio Rubio <srubio@abiquo.com> - 0.3.8-1
- Updated to upstream 0.3.8

* Tue Sep 21 2010 : Sergio Rubio <srubio@abiquo.com> - 0.3.7-1
- Updated to upstream 0.3.7

* Thu Sep 16 2010 : Sergio Rubio <srubio@abiquo.com> - 0.3.6-1
- Updated to upstream 0.3.6

* Tue Sep 07 2010 : Sergio Rubio <srubio@abiquo.com> - 0.3.5-1
- Updated to upstream 0.3.5

* Tue Sep 07 2010 : Sergio Rubio <srubio@abiquo.com> - 0.3.4-1
- Updated to upstream 0.3.4

* Mon Sep 06 2010 : Sergio Rubio <srubio@abiquo.com> - 0.3.3-1
- Updated to upstream 0.3.3

* Mon Aug 30 2010 : Sergio Rubio <srubio@abiquo.com> - 0.3.2-1
- Updated to upstream 0.3.2
* Mon Aug 30 2010 : Sergio Rubio <srubio@abiquo.com> - 0.3.1-1
- Updated to upstream 0.3.1
* Mon Aug 30 2010 : Sergio Rubio <srubio@abiquo.com> - 0.3-1
- Initial package
