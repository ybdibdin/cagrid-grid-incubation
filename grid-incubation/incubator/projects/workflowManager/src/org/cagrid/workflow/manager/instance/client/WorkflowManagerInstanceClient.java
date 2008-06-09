package org.cagrid.workflow.manager.instance.client;

import java.io.InputStream;
import java.rmi.RemoteException;

import javax.xml.namespace.QName;

import org.apache.axis.EngineConfiguration;
import org.apache.axis.client.AxisClient;
import org.apache.axis.client.Stub;
import org.apache.axis.configuration.FileProvider;
import org.apache.axis.message.addressing.EndpointReferenceType;
import org.apache.axis.types.URI.MalformedURIException;

import org.oasis.wsrf.properties.GetResourcePropertyResponse;

import org.globus.gsi.GlobusCredential;

import org.cagrid.workflow.manager.instance.stubs.WorkflowManagerInstancePortType;
import org.cagrid.workflow.manager.instance.stubs.service.WorkflowManagerInstanceServiceAddressingLocator;
import org.cagrid.workflow.manager.instance.common.WorkflowManagerInstanceI;
import gov.nih.nci.cagrid.introduce.security.client.ServiceSecurityClient;

/**
 * This class is autogenerated, DO NOT EDIT GENERATED GRID SERVICE ACCESS METHODS.
 *
 * This client is generated automatically by Introduce to provide a clean unwrapped API to the
 * service.
 *
 * On construction the class instance will contact the remote service and retrieve it's security
 * metadata description which it will use to configure the Stub specifically for each method call.
 * 
 * @created by Introduce Toolkit version 1.2
 */
public class WorkflowManagerInstanceClient extends WorkflowManagerInstanceClientBase implements WorkflowManagerInstanceI {	

	public WorkflowManagerInstanceClient(String url) throws MalformedURIException, RemoteException {
		this(url,null);	
	}

	public WorkflowManagerInstanceClient(String url, GlobusCredential proxy) throws MalformedURIException, RemoteException {
	   	super(url,proxy);
	}
	
	public WorkflowManagerInstanceClient(EndpointReferenceType epr) throws MalformedURIException, RemoteException {
	   	this(epr,null);
	}
	
	public WorkflowManagerInstanceClient(EndpointReferenceType epr, GlobusCredential proxy) throws MalformedURIException, RemoteException {
	   	super(epr,proxy);
	}

	public static void usage(){
		System.out.println(WorkflowManagerInstanceClient.class.getName() + " -url <service url>");
	}
	
	public static void main(String [] args){
	    System.out.println("Running the Grid Service Client");
		try{
		if(!(args.length < 2)){
			if(args[0].equals("-url")){
			  WorkflowManagerInstanceClient client = new WorkflowManagerInstanceClient(args[1]);
			  // place client calls here if you want to use this main as a
			  // test....
			} else {
				usage();
				System.exit(1);
			}
		} else {
			usage();
			System.exit(1);
		}
		} catch (Exception e) {
			e.printStackTrace();
			System.exit(1);
		}
	}

  public org.oasis.wsrf.lifetime.DestroyResponse destroy(org.oasis.wsrf.lifetime.Destroy params) throws RemoteException {
    synchronized(portTypeMutex){
      configureStubSecurity((Stub)portType,"destroy");
    return portType.destroy(params);
    }
  }

  public org.oasis.wsrf.lifetime.SetTerminationTimeResponse setTerminationTime(org.oasis.wsrf.lifetime.SetTerminationTime params) throws RemoteException {
    synchronized(portTypeMutex){
      configureStubSecurity((Stub)portType,"setTerminationTime");
    return portType.setTerminationTime(params);
    }
  }

  public org.cagrid.workflow.helper.descriptor.TimestampedStatus getTimestampedStatus() throws RemoteException {
    synchronized(portTypeMutex){
      configureStubSecurity((Stub)portType,"getTimestampedStatus");
    org.cagrid.workflow.manager.instance.stubs.GetTimestampedStatusRequest params = new org.cagrid.workflow.manager.instance.stubs.GetTimestampedStatusRequest();
    org.cagrid.workflow.manager.instance.stubs.GetTimestampedStatusResponse boxedResult = portType.getTimestampedStatus(params);
    return boxedResult.getTimestampedStatus();
    }
  }

  public void setParameter(org.cagrid.workflow.helper.descriptor.InputParameter inputParameter) throws RemoteException {
    synchronized(portTypeMutex){
      configureStubSecurity((Stub)portType,"setParameter");
    org.cagrid.workflow.helper.invocation.SetParameterRequest params = new org.cagrid.workflow.helper.invocation.SetParameterRequest();
    org.cagrid.workflow.helper.invocation.SetParameterRequestInputParameter inputParameterContainer = new org.cagrid.workflow.helper.invocation.SetParameterRequestInputParameter();
    inputParameterContainer.setInputParameter(inputParameter);
    params.setInputParameter(inputParameterContainer);
    org.cagrid.workflow.helper.invocation.SetParameterResponse boxedResult = portType.setParameter(params);
    }
  }

  public java.lang.String[] getOutputValues() throws RemoteException {
    synchronized(portTypeMutex){
      configureStubSecurity((Stub)portType,"getOutputValues");
    org.cagrid.workflow.manager.instance.stubs.GetOutputValuesRequest params = new org.cagrid.workflow.manager.instance.stubs.GetOutputValuesRequest();
    org.cagrid.workflow.manager.instance.stubs.GetOutputValuesResponse boxedResult = portType.getOutputValues(params);
    return boxedResult.getResponse();
    }
  }

}
