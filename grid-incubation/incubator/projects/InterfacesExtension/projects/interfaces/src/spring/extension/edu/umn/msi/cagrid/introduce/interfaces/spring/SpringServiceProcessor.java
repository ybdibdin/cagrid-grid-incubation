/**
*============================================================================
*  Copyright The Ohio State University Research Foundation, The University of Chicago - 
*	Argonne National Laboratory, Emory University, SemanticBits LLC, and 
*	Ekagra Software Technologies Ltd.
*
*  Distributed under the OSI-approved BSD 3-Clause License.
*  See http://ncip.github.com/cagrid-core/LICENSE.txt for details.
*============================================================================
**/
package edu.umn.msi.cagrid.introduce.interfaces.spring;

import edu.umn.msi.cagrid.introduce.interfaces.services.CaGridService;
import edu.umn.msi.cagrid.introduce.interfaces.services.Service;
import edu.umn.msi.cagrid.introduce.interfaces.services.ServiceProcessor;

public class SpringServiceProcessor implements ServiceProcessor {
  private SpringConfiguration springConfiguration;
  
  public SpringServiceProcessor(CaGridService caGridService, SpringConfiguration springConfiguration) {
    this.springConfiguration = springConfiguration;
  }
  
  public void execute(Service service) throws Exception {
    String serviceName = service.getName();
    StringBuffer serviceSource = new StringBuffer(service.getServiceImplContents());
    ServiceImplProcessor implProcessor = new ServiceImplProcessor(serviceSource,  serviceName, service.getCaGridService().getMainService().getName(), springConfiguration);
    implProcessor.execute();
    service.setServiceImplContents(serviceSource.toString());
  }
}