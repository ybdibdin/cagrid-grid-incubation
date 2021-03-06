/**
*============================================================================
*  The Ohio State University Research Foundation, Emory University,
*  the University of Minnesota Supercomputing Institute
*
*  Distributed under the OSI-approved BSD 3-Clause License.
*  See http://ncip.github.com/cagrid-grid-incubation/LICENSE.txt for details.
*============================================================================
**/
/**
*============================================================================
*============================================================================
**/
package org.cagrid.introduce.service2.client;

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

import org.cagrid.introduce.service2.stubs.Service2PortType;
import org.cagrid.introduce.service2.stubs.service.Service2ServiceAddressingLocator;
import org.cagrid.introduce.service2.common.Service2I;
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
 * @created by Introduce Toolkit version 1.1
 */
public class Service2Client extends ServiceSecurityClient implements Service2I {	
	protected Service2PortType portType;
	private Object portTypeMutex;

	public Service2Client(String url) throws MalformedURIException, RemoteException {
		this(url,null);	
	}

	public Service2Client(String url, GlobusCredential proxy) throws MalformedURIException, RemoteException {
	   	super(url,proxy);
	   	initialize();
	}
	
	public Service2Client(EndpointReferenceType epr) throws MalformedURIException, RemoteException {
	   	this(epr,null);
	}
	
	public Service2Client(EndpointReferenceType epr, GlobusCredential proxy) throws MalformedURIException, RemoteException {
	   	super(epr,proxy);
		initialize();
	}
	
	private void initialize() throws RemoteException {
	    this.portTypeMutex = new Object();
		this.portType = createPortType();
	}

	private Service2PortType createPortType() throws RemoteException {

		Service2ServiceAddressingLocator locator = new Service2ServiceAddressingLocator();
		// attempt to load our context sensitive wsdd file
		InputStream resourceAsStream = getClass().getResourceAsStream("client-config.wsdd");
		if (resourceAsStream != null) {
			// we found it, so tell axis to configure an engine to use it
			EngineConfiguration engineConfig = new FileProvider(resourceAsStream);
			// set the engine of the locator
			locator.setEngine(new AxisClient(engineConfig));
		}
		Service2PortType port = null;
		try {
			port = locator.getService2PortTypePort(getEndpointReference());
		} catch (Exception e) {
			throw new RemoteException("Unable to locate portType:" + e.getMessage(), e);
		}

		return port;
	}
	

	public static void usage(){
		System.out.println(Service2Client.class.getName() + " -url <service url>");
	}
	
	public static void main(String [] args){
	    System.out.println("Running the Grid Service Client");
		try{
		if(!(args.length < 2)){
			if(args[0].equals("-url")){
			  Service2Client client = new Service2Client(args[1]);
			  // place client calls here if you want to use this main as a
			  // test....
			  String uncapitalized = "andre cardoso de souza";
			  
			  System.out.println("Sending string: "+ uncapitalized);
			  
			  String output = client.capitalize(uncapitalized);
			  
			  System.out.println("Rceived: ");
			  System.out.println(output);
			  
			  
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

  public java.lang.String capitalize(java.lang.String uncapitalized) throws RemoteException {
    synchronized(portTypeMutex){
      configureStubSecurity((Stub)portType,"capitalize");
    org.cagrid.introduce.service2.stubs.CapitalizeRequest params = new org.cagrid.introduce.service2.stubs.CapitalizeRequest();
    params.setUncapitalized(uncapitalized);
    org.cagrid.introduce.service2.stubs.CapitalizeResponse boxedResult = portType.capitalize(params);
    return boxedResult.getResponse();
    }
  }

  public java.lang.String secureCapitalize(java.lang.String uncapitalized) throws RemoteException {
    synchronized(portTypeMutex){
      configureStubSecurity((Stub)portType,"secureCapitalize");
    org.cagrid.introduce.service2.stubs.SecureCapitalizeRequest params = new org.cagrid.introduce.service2.stubs.SecureCapitalizeRequest();
    params.setUncapitalized(uncapitalized);
    org.cagrid.introduce.service2.stubs.SecureCapitalizeResponse boxedResult = portType.secureCapitalize(params);
    return boxedResult.getResponse();
    }
  }

}
