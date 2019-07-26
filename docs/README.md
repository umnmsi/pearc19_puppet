## Using these materials

The materials below are provided particularly in hopes that they might help others
to recreate some or all of the techniques practiced at the Minnesota Supercomputing
Institute to manage systems with [Puppet](https://puppet.com/). A careful read of the
full paper will provide additional context, but we do not necessarily assume you have
done so and provide some explanation of each item.

Codes and configuration files tend to be unaltered from those in use at MSI, and in
some cases we refer you to the living canonical repository that MSI builds against.
As a result, some materials include MSI names and nomenclature that render them 
unsuitable for direct copy/paste usage. We believe they are still valuable
references to readers with detailed questions, and as examples for operators creating
similar deployments.

### Simple Puppet Provisioner

**Source code/homepage**: [https://github.com/umnmsi/SimplePuppetProvisioner](https://github.com/umnmsi/SimplePuppetProvisioner).
  
**MSI's configuration file**: [spp.conf.yml.erb](https://github.com/umnmsi/pearc19_puppet/blob/master/msi_configs/spp.conf.yml.erb).
(This is left as an [erb template](https://puppet.com/docs/puppet/5.3/lang_template_erb.html);
erb replaces some `<%= @some_property %>` sections with MSI's secret values.)  
**Bash scripts called by config file**:
  * [spp-r10k-sync.sh](https://github.com/umnmsi/pearc19_puppet/blob/master/msi_configs/spp-r10k-sync.sh).
    Wraps `r10k` to call it efficiently based on the nature of the git change. `r10k` runs
    can take a very long time on each commit otherwise.
  * [spp-status-filter.sh](https://github.com/umnmsi/pearc19_puppet/blob/master/msi_configs/spp-status-filter.sh).
    Filters some notifications from our google chat channel.
    
**Systemd unit file**: [SimplePuppetProvisioner.service](https://github.com/umnmsi/pearc19_puppet/blob/master/msi_configs/SimplePuppetProvisioner.service).

### Control Repository Template

This modification of the [official control repository template](https://github.com/puppetlabs/control-repo) incorporates support for
envlink in the modulepath and external hiera repos, and supports hiera levels based on the
node's role.  
We start from this template when we need to create a control repository for
a new cluster at MSI.

**Source code**: [https://github.com/umnmsi/control_repository_template](https://github.com/umnmsi/control_repository_template).

### PDK Template

This template for PDK causes new modules that we create to include Jenkins CI support. We've
also made it feasible to write rspec tests involving dependent modules that include eyaml,
without requiring the private key to be in Jenkins or on developer workstations.
It's based on [https://github.com/puppetlabs/pdk-templates](https://github.com/puppetlabs/pdk-templates).

**Source code**: [https://github.com/umnmsi/puppet-pdk-templates](https://github.com/umnmsi/puppet-pdk-templates)

### r10k configuration file
[r10k.yaml](https://github.com/umnmsi/r10k_config/blob/master/r10k.yaml)

### envlink

**Source code/homepage**: [https://github.com/umnmsi/envlink](https://github.com/umnmsi/envlink).

**MSI's configuration file**: [envlink.yaml](https://github.com/umnmsi/r10k_config/blob/master/envlink.yaml)

### hiera-enc

We have slightly modified an open-source tool to also work with with `mapped_paths` in hiera.yaml (see control repo template.)  
**Source code**: [https://github.com/umnmsi/puppet-hiera-enc](https://github.com/umnmsi/puppet-hiera-enc)

This allows us to define in a node's hiera yaml a primary role that also includes a "base"
role's yaml. For example:
```yaml
parameters:
  primary_role: ldap_server__master
```
will result in hiera data from both an `ldap_server.yaml` and an `ldap_server__master.yaml`
role yaml file be consulted.