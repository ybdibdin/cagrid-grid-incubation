package org.cagrid.workflow.helper.invocation.client;

import java.io.PrintStream;
import java.rmi.RemoteException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.xml.namespace.QName;

import org.apache.axis.client.Stub;
import org.apache.axis.message.MessageElement;
import org.apache.axis.message.addressing.EndpointReferenceType;
import org.apache.axis.types.URI.MalformedURIException;
import org.cagrid.workflow.helper.descriptor.TimestampedStatus;
import org.cagrid.workflow.helper.invocation.common.WorkflowInvocationHelperI;
import org.globus.gsi.GlobusCredential;
import org.globus.wsrf.NotifyCallback;
import org.globus.wsrf.container.ContainerException;

/**
 * This class is autogenerated, DO NOT EDIT GENERATED GRID SERVICE ACCESS
 * METHODS.
 * 
 * This client is generated automatically by Introduce to provide a clean
 * unwrapped API to the service.
 * 
 * On construction the class instance will contact the remote service and
 * retrieve it's security metadata description which it will use to configure
 * the Stub specifically for each method call.
 * 
 * @created by Introduce Toolkit version 1.2
 */
public class WorkflowInvocationHelperClient extends
WorkflowInvocationHelperClientBase implements WorkflowInvocationHelperI {

	public Map<QName, NotifyCallback> callbacks = new HashMap<QName, NotifyCallback>();

	public WorkflowInvocationHelperClient(String url)
	throws MalformedURIException, RemoteException {
		this(url, null);
	}

	public WorkflowInvocationHelperClient(String url, GlobusCredential proxy)
	throws MalformedURIException, RemoteException {
		super(url, proxy);
	}

	public WorkflowInvocationHelperClient(EndpointReferenceType epr)
	throws MalformedURIException, RemoteException {
		this(epr, null);
	}

	public WorkflowInvocationHelperClient(EndpointReferenceType epr,
			GlobusCredential proxy) throws MalformedURIException,
			RemoteException {
		super(epr, proxy);
	}

	public static void usage() {
		System.out.println(WorkflowInvocationHelperClient.class.getName()
				+ " -url <service url>");
	}

	public static void main(String[] args) {
		System.out.println("Running the Grid Service Client");
		try {
			if (!(args.length < 2)) {
				if (args[0].equals("-url")) {
					WorkflowInvocationHelperClient client = new WorkflowInvocationHelperClient(
							args[1]);
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

	
	
	public org.oasis.wsn.SubscribeResponse subscribeWithCallback(QName qname, NotifyCallback callback) throws RemoteException, ContainerException, MalformedURIException {

		//System.out.print("[subscribe] Putting "+ qname +" on internal list"); //DEBUG

		callbacks.put(qname, callback);

		//System.out.println("...OK"); // DEBUG

		return subscribe(qname);
	} 
	

	
	// DON'T REMOVE OR UNCOMMENT THE subscribe METHOD BELOW!!
	/*public org.oasis.wsn.SubscribeResponse subscribe(QName qname, NotifyCallback callback) throws RemoteException, ContainerException, MalformedURIException {

		//System.out.print("[subscribe] Putting "+ qname +" on internal list"); //DEBUG

		callbacks.put(qname, callback);

		//System.out.println("...OK"); // DEBUG

		return subscribe(qname);
	} // */

	public void deliver(List topicPath, EndpointReferenceType producer,
			Object message) {
		org.oasis.wsrf.properties.ResourcePropertyValueChangeNotificationType changeMessage = ((org.globus.wsrf.core.notification.ResourcePropertyValueChangeNotificationElementType) message)
		.getResourcePropertyValueChangeNotification();

		MessageElement messageToDeliver = changeMessage.getNewValue().get_any()[0];
		QName notification_qname = messageToDeliver.getQName();
		String stageKey = null;
		try {
			stageKey = new WorkflowInvocationHelperClient(producer).getEPRString(); //toString();
		} catch (RemoteException e1) {
			e1.printStackTrace();
		} catch (MalformedURIException e1) {
			e1.printStackTrace();
		}  

		PrintStream log = System.out;  //DEBUG
		TimestampedStatus messageValue = null;
		try {
			messageValue = (TimestampedStatus) messageToDeliver.getValueAsType(notification_qname, TimestampedStatus.class);
		} catch (Exception e) {
			e.printStackTrace();
		} // */
		//log.println("[WorkflowInvocationHelper.deliver] Received message: "+ messageValue.toString() + " from "+ stageKey);  //DEBUG

		if(callbacks.containsKey(notification_qname)){

			//DEBUG
			//log.println("[WorkflowInvocationHelperClient.deliver] Delivering "+ notification_qname);

			(callbacks.get(notification_qname)).deliver(topicPath, producer, message);

			//log.println("Delivered");

		}
		else {

			System.out.println("[WorkflowInvocationHelperClient.deliver] Don't know how to deliver object of type "+ notification_qname); 

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

  public void configureInput(org.cagrid.workflow.helper.descriptor.OperationInputMessageDescriptor operationInputMessageDescriptor) throws RemoteException {
    synchronized(portTypeMutex){
      configureStubSecurity((Stub)portType,"configureInput");
    org.cagrid.workflow.helper.invocation.stubs.ConfigureInputRequest params = new org.cagrid.workflow.helper.invocation.stubs.ConfigureInputRequest();
    org.cagrid.workflow.helper.invocation.stubs.ConfigureInputRequestOperationInputMessageDescriptor operationInputMessageDescriptorContainer = new org.cagrid.workflow.helper.invocation.stubs.ConfigureInputRequestOperationInputMessageDescriptor();
    operationInputMessageDescriptorContainer.setOperationInputMessageDescriptor(operationInputMessageDescriptor);
    params.setOperationInputMessageDescriptor(operationInputMessageDescriptorContainer);
    org.cagrid.workflow.helper.invocation.stubs.ConfigureInputResponse boxedResult = portType.configureInput(params);
    }
  }

  public void configureOutput(org.cagrid.workflow.helper.descriptor.OperationOutputTransportDescriptor operationOutputTransportDescriptor) throws RemoteException {
    synchronized(portTypeMutex){
      configureStubSecurity((Stub)portType,"configureOutput");
    org.cagrid.workflow.helper.invocation.stubs.ConfigureOutputRequest params = new org.cagrid.workflow.helper.invocation.stubs.ConfigureOutputRequest();
    org.cagrid.workflow.helper.invocation.stubs.ConfigureOutputRequestOperationOutputTransportDescriptor operationOutputTransportDescriptorContainer = new org.cagrid.workflow.helper.invocation.stubs.ConfigureOutputRequestOperationOutputTransportDescriptor();
    operationOutputTransportDescriptorContainer.setOperationOutputTransportDescriptor(operationOutputTransportDescriptor);
    params.setOperationOutputTransportDescriptor(operationOutputTransportDescriptorContainer);
    org.cagrid.workflow.helper.invocation.stubs.ConfigureOutputResponse boxedResult = portType.configureOutput(params);
    }
  }

  public void setParameter(org.cagrid.workflow.helper.descriptor.InputParameter inputParameter) throws RemoteException {
    synchronized(portTypeMutex){
      configureStubSecurity((Stub)portType,"setParameter");
    org.cagrid.workflow.helper.invocation.stubs.SetParameterRequest params = new org.cagrid.workflow.helper.invocation.stubs.SetParameterRequest();
    org.cagrid.workflow.helper.invocation.stubs.SetParameterRequestInputParameter inputParameterContainer = new org.cagrid.workflow.helper.invocation.stubs.SetParameterRequestInputParameter();
    inputParameterContainer.setInputParameter(inputParameter);
    params.setInputParameter(inputParameterContainer);
    org.cagrid.workflow.helper.invocation.stubs.SetParameterResponse boxedResult = portType.setParameter(params);
    }
  }

  public void setParameters(org.cagrid.workflow.helper.descriptor.InputParameter[] inputParameters) throws RemoteException {
    synchronized(portTypeMutex){
      configureStubSecurity((Stub)portType,"setParameters");
    org.cagrid.workflow.helper.invocation.stubs.SetParametersRequest params = new org.cagrid.workflow.helper.invocation.stubs.SetParametersRequest();
    org.cagrid.workflow.helper.invocation.stubs.SetParametersRequestInputParameters inputParametersContainer = new org.cagrid.workflow.helper.invocation.stubs.SetParametersRequestInputParameters();
    inputParametersContainer.setInputParameter(inputParameters);
    params.setInputParameters(inputParametersContainer);
    org.cagrid.workflow.helper.invocation.stubs.SetParametersResponse boxedResult = portType.setParameters(params);
    }
  }

  public org.oasis.wsn.SubscribeResponse subscribe(org.oasis.wsn.Subscribe params) throws RemoteException {
    synchronized(portTypeMutex){
      configureStubSecurity((Stub)portType,"subscribe");
    return portType.subscribe(params);
    }
  }

  public java.lang.String getEPRString() throws RemoteException {
    synchronized(portTypeMutex){
      configureStubSecurity((Stub)portType,"getEPRString");
    org.cagrid.workflow.helper.invocation.stubs.GetEPRStringRequest params = new org.cagrid.workflow.helper.invocation.stubs.GetEPRStringRequest();
    org.cagrid.workflow.helper.invocation.stubs.GetEPRStringResponse boxedResult = portType.getEPRString(params);
    return boxedResult.getResponse();
    }
  }

}
