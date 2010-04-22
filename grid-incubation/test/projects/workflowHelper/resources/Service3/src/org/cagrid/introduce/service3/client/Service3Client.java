package org.cagrid.introduce.service3.client;

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

import org.cagrid.introduce.service3.stubs.Service3PortType;
import org.cagrid.introduce.service3.stubs.service.Service3ServiceAddressingLocator;
import org.cagrid.introduce.service3.common.Service3I;
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
public class Service3Client extends ServiceSecurityClient implements Service3I {	
	protected Service3PortType portType;
	private Object portTypeMutex;

	public Service3Client(String url) throws MalformedURIException, RemoteException {
		this(url,null);	
	}

	public Service3Client(String url, GlobusCredential proxy) throws MalformedURIException, RemoteException {
	   	super(url,proxy);
	   	initialize();
	}
	
	public Service3Client(EndpointReferenceType epr) throws MalformedURIException, RemoteException {
	   	this(epr,null);
	}
	
	public Service3Client(EndpointReferenceType epr, GlobusCredential proxy) throws MalformedURIException, RemoteException {
	   	super(epr,proxy);
		initialize();
	}
	
	private void initialize() throws RemoteException {
	    this.portTypeMutex = new Object();
		this.portType = createPortType();
	}

	private Service3PortType createPortType() throws RemoteException {

		Service3ServiceAddressingLocator locator = new Service3ServiceAddressingLocator();
		// attempt to load our context sensitive wsdd file
		InputStream resourceAsStream = getClass().getResourceAsStream("client-config.wsdd");
		if (resourceAsStream != null) {
			// we found it, so tell axis to configure an engine to use it
			EngineConfiguration engineConfig = new FileProvider(resourceAsStream);
			// set the engine of the locator
			locator.setEngine(new AxisClient(engineConfig));
		}
		Service3PortType port = null;
		try {
			port = locator.getService3PortTypePort(getEndpointReference());
		} catch (Exception e) {
			throw new RemoteException("Unable to locate portType:" + e.getMessage(), e);
		}

		return port;
	}
	

	public static void usage(){
		System.out.println(Service3Client.class.getName() + " -url <service url>");
	}
	
	public static void main(String [] args){
	    System.out.println("Running the Grid Service Client");
		try{
		if(!(args.length < 2)){
			if(args[0].equals("-url")){
			  Service3Client client = new Service3Client(args[1]);
			  // place client calls here if you want to use this main as a
			  // test....
			  
			  int str_length = 5;
			  
			  System.out.println("Sending length: "+str_length);
			  
			  String x = client.generateX(str_length);
			  
			  System.out.println("Received string: ");
			  System.out.println(x);			  
			  
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

  public java.lang.String generateX(int str_length) throws RemoteException {
    synchronized(portTypeMutex){
      configureStubSecurity((Stub)portType,"generateX");
    org.cagrid.introduce.service3.stubs.GenerateXRequest params = new org.cagrid.introduce.service3.stubs.GenerateXRequest();
    params.setStr_length(str_length);
    org.cagrid.introduce.service3.stubs.GenerateXResponse boxedResult = portType.generateX(params);
    return boxedResult.getResponse();
    }
  }

  public java.lang.String secureGenerateX(int str_length) throws RemoteException {
    synchronized(portTypeMutex){
      configureStubSecurity((Stub)portType,"secureGenerateX");
    org.cagrid.introduce.service3.stubs.SecureGenerateXRequest params = new org.cagrid.introduce.service3.stubs.SecureGenerateXRequest();
    params.setStr_length(str_length);
    org.cagrid.introduce.service3.stubs.SecureGenerateXResponse boxedResult = portType.secureGenerateX(params);
    return boxedResult.getResponse();
    }
  }

}