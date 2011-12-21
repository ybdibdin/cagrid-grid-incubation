package org.cagrid.workflow.manager.client;

import gov.nih.nci.cagrid.introduce.security.client.ServiceSecurityClient;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.rmi.RemoteException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

import javax.xml.namespace.QName;
import javax.xml.rpc.NamespaceConstants;

import junit.framework.Assert;

import org.apache.axis.EngineConfiguration;
import org.apache.axis.client.AxisClient;
import org.apache.axis.client.Stub;
import org.apache.axis.configuration.FileProvider;
import org.apache.axis.message.MessageElement;
import org.apache.axis.message.addressing.Address;
import org.apache.axis.message.addressing.AttributedURI;
import org.apache.axis.message.addressing.EndpointReference;
import org.apache.axis.message.addressing.EndpointReferenceType;
import org.apache.axis.types.URI.MalformedURIException;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.cagrid.gaards.cds.common.ProxyLifetime;
import org.cagrid.workflow.helper.descriptor.CDSAuthenticationMethod;
import org.cagrid.workflow.helper.descriptor.ChannelProtection;
import org.cagrid.workflow.helper.descriptor.DeliveryPolicy;
import org.cagrid.workflow.helper.descriptor.InputParameter;
import org.cagrid.workflow.helper.descriptor.InputParameterDescriptor;
import org.cagrid.workflow.helper.descriptor.OperationInputMessageDescriptor;
import org.cagrid.workflow.helper.descriptor.OperationOutputParameterTransportDescriptor;
import org.cagrid.workflow.helper.descriptor.OperationOutputTransportDescriptor;
import org.cagrid.workflow.helper.descriptor.OutputReady;
import org.cagrid.workflow.helper.descriptor.Status;
import org.cagrid.workflow.helper.descriptor.TLSInvocationSecurityDescriptor;
import org.cagrid.workflow.helper.descriptor.TimestampedStatus;
import org.cagrid.workflow.helper.descriptor.WorkflowInvocationHelperDescriptor;
import org.cagrid.workflow.helper.descriptor.WorkflowInvocationSecurityDescriptor;
import org.cagrid.workflow.helper.util.CredentialHandlingUtil;
import org.cagrid.workflow.manager.common.WorkflowManagerServiceI;
import org.cagrid.workflow.manager.descriptor.WorkflowInputParameter;
import org.cagrid.workflow.manager.descriptor.WorkflowInputParameters;
import org.cagrid.workflow.manager.descriptor.WorkflowManagerInstanceDescriptor;
import org.cagrid.workflow.manager.descriptor.WorkflowOutputParameterTransportDescriptor;
import org.cagrid.workflow.manager.descriptor.WorkflowOutputTransportDescriptor;
import org.cagrid.workflow.manager.descriptor.WorkflowPortionDescriptor;
import org.cagrid.workflow.manager.descriptor.WorkflowPortionsDescriptor;
import org.cagrid.workflow.manager.descriptor.WorkflowStageDescriptor;
import org.cagrid.workflow.manager.instance.client.WorkflowManagerInstanceClient;
import org.cagrid.workflow.manager.instance.stubs.types.WorkflowManagerInstanceReference;
import org.cagrid.workflow.manager.stubs.WorkflowManagerServicePortType;
import org.cagrid.workflow.manager.stubs.service.WorkflowManagerServiceAddressingLocator;
import org.cagrid.workflow.manager.util.WorkflowDescriptorParser;
import org.globus.gsi.GlobusCredential;
import org.globus.wsrf.NotifyCallback;
import org.globus.wsrf.container.ContainerException;

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
public class WorkflowManagerServiceClient extends ServiceSecurityClient implements WorkflowManagerServiceI, NotifyCallback {	
	protected WorkflowManagerServicePortType portType;
	private Object portTypeMutex;

	// Synchronizes the access to variable 'isFinished' 
	protected Lock isFinishedKey = new ReentrantLock();
	protected Condition isFinishedCondition = isFinishedKey.newCondition();
	protected Map<String, TimestampedStatus> stageStatus = new HashMap<String, TimestampedStatus>() ;

	// Store the operation name for each service subscribed for notification 
	protected static Map<String, String> EPR2OperationName = new HashMap<String, String>();

	protected boolean isFinished = false;
	protected static List<EndpointReferenceType> managerInstances = new ArrayList<EndpointReferenceType>();

	final static String XSD_NAMESPACE = "http://www.w3.org/2001/XMLSchema";
	final static String SOAPENCODING_NAMESPACE = "http://schemas.xmlsoap.org/soap/encoding/";
	private static final String CONTAINERBASEPLACEHOLDER = "CONTAINERBASE";

	// Synchronization for asynchronous calls
	Map<String, Lock> asynchronousStartLock = new HashMap<String, Lock>();
	Map<String, Condition> asynchronousStartCondition = new HashMap<String, Condition>();
	Map<String, Boolean> asynchronousStartCallbackReceived = new HashMap<String, Boolean>();

	private static Log logger = LogFactory.getLog(WorkflowManagerServiceClient.class);

	public WorkflowManagerServiceClient(String url) throws MalformedURIException, RemoteException {
		this(url,null);	
	}

	public WorkflowManagerServiceClient(String url, GlobusCredential proxy) throws MalformedURIException, RemoteException {
		super(url,proxy);
		initialize();
	}

	public WorkflowManagerServiceClient(EndpointReferenceType epr) throws MalformedURIException, RemoteException {
		this(epr,null);
	}

	public WorkflowManagerServiceClient(EndpointReferenceType epr, GlobusCredential proxy) throws MalformedURIException, RemoteException {
		super(epr,proxy);
		initialize();
	}

	private void initialize() throws RemoteException {
		this.portTypeMutex = new Object();
		this.portType = createPortType();
	}

	private WorkflowManagerServicePortType createPortType() throws RemoteException {

		WorkflowManagerServiceAddressingLocator locator = new WorkflowManagerServiceAddressingLocator();
		// attempt to load our context sensitive wsdd file
		InputStream resourceAsStream = getClass().getResourceAsStream("client-config.wsdd");
		if (resourceAsStream != null) {
			// we found it, so tell axis to configure an engine to use it
			EngineConfiguration engineConfig = new FileProvider(resourceAsStream);
			// set the engine of the locator
			locator.setEngine(new AxisClient(engineConfig));
		}
		WorkflowManagerServicePortType port = null;
		try {
			port = locator.getWorkflowManagerServicePortTypePort(getEndpointReference());
		} catch (Exception e) {
			throw new RemoteException("Unable to locate portType:" + e.getMessage(), e);
		}

		return port;
	}

	public static void usage(){
		System.out.println(WorkflowManagerServiceClient.class.getName() + " -url <service url>");
	}

	/** Store the contents of a file in a String */
	private static String readFileToString(File wfDescriptor) {

		int fileLenght = (int) wfDescriptor.length();
		String retval = null;

		try {
			FileReader reader = new FileReader(wfDescriptor);
			char[] cbuf = new char[fileLenght];
			reader.read(cbuf);

			retval = new String(cbuf);

		} catch(IOException ioe){
			logger.error(ioe.getMessage(), ioe);
		}

		return retval;
	}

	public static void main(String [] args){
		System.out.println("Running the Grid Service Client");
		try{
			if(!(args.length < 2)){
				if(args[0].equals("-url")){
					WorkflowManagerServiceClient client = new WorkflowManagerServiceClient(args[1]);
					// place client calls here if you want to use this main as a
					// test....
					// Read descriptor into a string
					String wfDescriptorFilename = null;
					try {
						File sampleDescriptorsDirectory = new File("/home/andrecs/subversion_caOS/trunk/grid-incubation/test/projects/workflowManager/resources/workflowDescriptionSamples");
						wfDescriptorFilename = sampleDescriptorsDirectory .getCanonicalFile() + File.separator + "UnsecureWorkflowSimpleArray.xml";
					} catch (IOException e) {
						logger.error(e.getMessage(), e);
						e.printStackTrace();
					}

					File wfDescriptor = new File(wfDescriptorFilename);
					String wfXmlDescriptor = readFileToString(wfDescriptor);

					// Replace the URLs in the descriptor with the actual container URL	
					String containerBaseURL = "http://localhost:"+ Integer.parseInt(System.getProperty("tomcat.port")) +"/wsrf/services";
					wfXmlDescriptor = wfXmlDescriptor.replaceAll(CONTAINERBASEPLACEHOLDER, containerBaseURL);

					// Create and execute the workflow
					WorkflowManagerInstanceClient managerInstanceClient = null;
//					WorkflowManagerServiceClient receiveNotifications = new WorkflowManagerServiceClient(args[1]);
					Lock asynchronousCallbackLock = null;
					String clientID = null;
					try {

						WorkflowManagerInstanceDescriptor wfDesc = new WorkflowDescriptorParser().parseWorkflowDescriptor(wfXmlDescriptor);
						WorkflowManagerInstanceReference managerInstanceRef = client.createWorkflowManagerInstanceFromObjectDescriptor(wfDesc);
						managerInstanceClient = new WorkflowManagerInstanceClient(managerInstanceRef.getEndpointReference());

						// Initialize synchronization variables so we can handle future notifications of execution end
						clientID = managerInstanceClient.getEPRString(); 
						if(clientID == null){
							throw new RemoteException("Unable to retrieve EPR String");
						}
//						receiveNotifications.asynchronousStartCallbackReceived.put(clientID, false);
//						asynchronousCallbackLock = new ReentrantLock();
//						receiveNotifications.asynchronousStartLock.put(clientID, asynchronousCallbackLock);
//						receiveNotifications.asynchronousStartCondition.put(clientID, asynchronousCallbackLock.newCondition());  

//						managerInstanceClient.subscribeWithCallback(OutputReady.getTypeDesc().getXmlType(), receiveNotifications);

					} catch (MalformedURIException e) {
						logger.error(e.getMessage() ,e);
						e.printStackTrace();
					} catch (ContainerException e) {
						logger.error(e.getMessage() ,e);
						e.printStackTrace();
					} catch (Exception e) {
						logger.error(e.getMessage() ,e);
						e.printStackTrace();
					} 

					managerInstanceClient.start();  // Start asynchronous execution

					// Wait for asynchornous method callback
//					asynchronousCallbackLock.lock();
//					try {
//
//						if(!receiveNotifications.asynchronousStartCallbackReceived.get(clientID)){
//
//							Condition currWorkflowCondition = receiveNotifications.asynchronousStartCondition.get(clientID);
//							logger.info("Blocking on condition variable");
//							currWorkflowCondition.await();  // Blocks until execution is finished
//							logger.info("Workflow is finished");
//						}
//
//					} catch (InterruptedException e) {
//						logger.error(e.getMessage() ,e);
//						e.printStackTrace();
//					} finally {
//						asynchronousCallbackLock.unlock();
//					}

					String[] outputs = managerInstanceClient.getOutputValues();  // Retrieve the outputs for this workflow

					// Print retrieved outputs
					if(outputs != null){
						logger.info("Printing workflow outputs");
						for(int i=0; i < outputs.length; i++){

							logger.info("Output #"+ i +" is "+ outputs[i]);
						}
						logger.info("End outputs");
					}

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

	public void deliver(List arg0, EndpointReferenceType arg1, Object arg2) {

		org.oasis.wsrf.properties.ResourcePropertyValueChangeNotificationType changeMessage = ((org.globus.wsrf.core.notification.ResourcePropertyValueChangeNotificationElementType) arg2)
		.getResourcePropertyValueChangeNotification();

		MessageElement actual_property = changeMessage.getNewValue().get_any()[0];
		QName message_qname = actual_property.getQName();
		boolean isTimestampedStatusChange = message_qname.equals(TimestampedStatus.getTypeDesc().getXmlType());
		boolean isOutputReady = message_qname.equals(OutputReady.getTypeDesc().getXmlType());
		String stageKey = null;
		try {
			stageKey = new WorkflowManagerInstanceClient(arg1).getEPRString();  
		} catch (RemoteException e1) {
			e1.printStackTrace();
		} catch (MalformedURIException e1) {
			e1.printStackTrace();
		}   

		logger.info("[CreateTestWorkflowsStep] Received message of type "+ message_qname.getLocalPart() +" from "+ stageKey);

		// Handle status change notifications
		if(isTimestampedStatusChange){
			TimestampedStatus status = null;;
			try {
				status = (TimestampedStatus) actual_property.getValueAsType(message_qname, TimestampedStatus.class);
			} catch (Exception e) {
				e.printStackTrace();
			}

			logger.info("Received new status value: "+ status.getStatus().toString() + ':' + status.getTimestamp());

			this.isFinishedKey.lock();
			try{

				boolean statusActuallyChanged = false;
				if( this.stageStatus.containsKey(stageKey) ){

					TimestampedStatus curr_status = this.stageStatus.get(stageKey);
					statusActuallyChanged = ( curr_status.getTimestamp() < status.getTimestamp() ); 										

					if(statusActuallyChanged){

						this.stageStatus.remove(stageKey);
						this.stageStatus.put(stageKey, status);
					}

				}
				else logger.warn("Unrecognized stage notified status change: "+ stageKey);

				if( statusActuallyChanged && (status.getStatus().equals(Status.FINISHED) || status.getStatus().equals(Status.ERROR)) ){

					this.isFinished  = this.hasFinished(); 

					if(this.isFinished){

						this.isFinishedCondition.signalAll();
						Assert.assertFalse(this.stageStatus.containsValue(Status.ERROR));
						
					}
				}
			}
			finally {
				this.isFinishedKey.unlock();
			}
		}

		// Handle callbacks received from just finished workflows
		else if(isOutputReady){

			stageKey = null;
			try {
				stageKey = new WorkflowManagerInstanceClient(arg1).getEPRString();    

				if(stageKey == null){
					logger.error("[RunSecureWorkflowsStep::deliver] Unable to retrieve stageKey");
				}

			} catch (RemoteException e1) {
				e1.printStackTrace();
				logger.error(e1.getMessage(), e1);
			} catch (MalformedURIException e1) {
				e1.printStackTrace();
				logger.error(e1.getMessage(), e1);
			} 

			OutputReady callback = null;
			try {
				callback = (OutputReady) actual_property.getValueAsType(message_qname, OutputReady.class);
			} catch (Exception e) {
				e.printStackTrace();
			}

			Boolean notificationValue = new Boolean(callback.equals(OutputReady.TRUE));
			System.out.println("Received new OutputReady: "+ callback.getValue() + " from "+ stageKey); //DEBUG

			// Store/Update the value stored internally for the current InvocationHelper
			Lock mutex = this.asynchronousStartLock.get(stageKey);
			mutex.lock();
			try {

				this.asynchronousStartCallbackReceived.put(stageKey, notificationValue);

				// If the execution is finished, report the user
				boolean allCallbacksReceived = !this.asynchronousStartCallbackReceived.containsValue(Boolean.FALSE);
				if(allCallbacksReceived){

					System.out.println("[RunSecureWorkflowsStep::deliver] All callbacks received. Execution is finished."); 
					Condition workflowFinished = this.asynchronousStartCondition.get(stageKey);
					workflowFinished.signalAll();
				}

			} finally {
				mutex.unlock();
			}
		}
		else{
			logger.error("[RunUnsecureWorkflowStepFromXML::deliver] Callback received from an unknown stage: "+ stageKey);
		}

	}

	/**
	 * Verify whether all stages have already sent a termination notification  
	 * */
	protected boolean hasFinished() {

		Set<Entry<String, TimestampedStatus>> entries = this.stageStatus.entrySet();
		Iterator<Entry<String, TimestampedStatus>> entries_iter = entries.iterator();

		while( entries_iter.hasNext() ){

			Entry<String, TimestampedStatus> curr_entry = entries_iter.next();
			boolean stageEnded =   curr_entry.getValue().getStatus().equals(Status.FINISHED)
			|| curr_entry.getValue().getStatus().equals(Status.ERROR);

			if( !stageEnded )  return false;

		}

		return true;
	}

  public org.oasis.wsrf.properties.GetMultipleResourcePropertiesResponse getMultipleResourceProperties(org.oasis.wsrf.properties.GetMultipleResourceProperties_Element params) throws RemoteException {
    synchronized(portTypeMutex){
      configureStubSecurity((Stub)portType,"getMultipleResourceProperties");
    return portType.getMultipleResourceProperties(params);
    }
  }

  public org.oasis.wsrf.properties.GetResourcePropertyResponse getResourceProperty(javax.xml.namespace.QName params) throws RemoteException {
    synchronized(portTypeMutex){
      configureStubSecurity((Stub)portType,"getResourceProperty");
    return portType.getResourceProperty(params);
    }
  }

  public org.oasis.wsrf.properties.QueryResourcePropertiesResponse queryResourceProperties(org.oasis.wsrf.properties.QueryResourceProperties_Element params) throws RemoteException {
    synchronized(portTypeMutex){
      configureStubSecurity((Stub)portType,"queryResourceProperties");
    return portType.queryResourceProperties(params);
    }
  }

  public org.cagrid.workflow.manager.instance.stubs.types.WorkflowManagerInstanceReference createWorkflowManagerInstanceFromObjectDescriptor(org.cagrid.workflow.manager.descriptor.WorkflowManagerInstanceDescriptor workflowDesc) throws RemoteException {
    synchronized(portTypeMutex){
      configureStubSecurity((Stub)portType,"createWorkflowManagerInstanceFromObjectDescriptor");
    org.cagrid.workflow.manager.stubs.CreateWorkflowManagerInstanceFromObjectDescriptorRequest params = new org.cagrid.workflow.manager.stubs.CreateWorkflowManagerInstanceFromObjectDescriptorRequest();
    org.cagrid.workflow.manager.stubs.CreateWorkflowManagerInstanceFromObjectDescriptorRequestWorkflowDesc workflowDescContainer = new org.cagrid.workflow.manager.stubs.CreateWorkflowManagerInstanceFromObjectDescriptorRequestWorkflowDesc();
    workflowDescContainer.setWorkflowManagerInstanceDescriptor(workflowDesc);
    params.setWorkflowDesc(workflowDescContainer);
    org.cagrid.workflow.manager.stubs.CreateWorkflowManagerInstanceFromObjectDescriptorResponse boxedResult = portType.createWorkflowManagerInstanceFromObjectDescriptor(params);
    return boxedResult.getWorkflowManagerInstanceReference();
    }
  }

  public java.lang.String getIdentity() throws RemoteException {
    synchronized(portTypeMutex){
      configureStubSecurity((Stub)portType,"getIdentity");
    org.cagrid.workflow.manager.stubs.GetIdentityRequest params = new org.cagrid.workflow.manager.stubs.GetIdentityRequest();
    org.cagrid.workflow.manager.stubs.GetIdentityResponse boxedResult = portType.getIdentity(params);
    return boxedResult.getResponse();
    }
  }

}
