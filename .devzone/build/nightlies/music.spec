
Name:           %{dz_repo}
Version:        %{dz_version} 
Release:        %{_vendor}%{?suse_version} 
Summary:        DevZone Projects Compiler 

Group:          Amusements/Games
License:        GPLv2
URL:            http://dev.openttdcoop.org

Source0:        %{name}-%{version}.tar

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-buildroot

BuildArch:      noarch

BuildRequires:  mercurial p7zip %{?dz_requires}

%description
Build script for #openttdcoop DevZone Music projects

%prep
%setup -qn %{name}

%build
make bundle_zip md5 ZIP="7za a" ZIP_FLAGS="-tzip -mx9" -j1 1>%{name}-%{version}-build.log 2>%{name}-%{version}-build.err.log

%install

%check

%clean

%files

%changelog
