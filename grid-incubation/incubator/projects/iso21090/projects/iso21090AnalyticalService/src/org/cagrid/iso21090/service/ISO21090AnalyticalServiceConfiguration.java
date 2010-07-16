package org.cagrid.iso21090.service;

import gov.nih.nci.cagrid.introduce.servicetools.ServiceConfiguration;

import org.globus.wsrf.config.ContainerConfig;
import java.io.File;
import javax.naming.InitialContext;

import org.apache.axis.MessageContext;
import org.globus.wsrf.Constants;


/** 
 * DO NOT EDIT:  This class is autogenerated!
 * 
 * This class holds all service properties which were defined for the service to have
 * access to.
 * 
 * @created by Introduce Toolkit version 1.3
 * 
 */
public class ISO21090AnalyticalServiceConfiguration implements ServiceConfiguration {

	public static ISO21090AnalyticalServiceConfiguration  configuration = null;
    public String etcDirectoryPath;
    	
	public static ISO21090AnalyticalServiceConfiguration getConfiguration() throws Exception {
		if (ISO21090AnalyticalServiceConfiguration.configuration != null) {
			return ISO21090AnalyticalServiceConfiguration.configuration;
		}
		MessageContext ctx = MessageContext.getCurrentContext();

		String servicePath = ctx.getTargetService();

		String jndiName = Constants.JNDI_SERVICES_BASE_NAME + servicePath + "/serviceconfiguration";
		try {
			javax.naming.Context initialContext = new InitialContext();
			ISO21090AnalyticalServiceConfiguration.configuration = (ISO21090AnalyticalServiceConfiguration) initialContext.lookup(jndiName);
		} catch (Exception e) {
			throw new Exception("Unable to instantiate service configuration.", e);
		}

		return ISO21090AnalyticalServiceConfiguration.configuration;
	}
	

	
	
    public String getEtcDirectoryPath() {
		return ContainerConfig.getBaseDirectory() + File.separator + etcDirectoryPath;
	}
	
	public void setEtcDirectoryPath(String etcDirectoryPath) {
		this.etcDirectoryPath = etcDirectoryPath;
	}


	
}
