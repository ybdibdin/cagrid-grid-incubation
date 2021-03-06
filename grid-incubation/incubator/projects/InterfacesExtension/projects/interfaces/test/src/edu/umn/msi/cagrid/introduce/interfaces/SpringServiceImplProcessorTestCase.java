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
package edu.umn.msi.cagrid.introduce.interfaces;

import edu.umn.msi.cagrid.introduce.interfaces.codegen.StringBufferUtils;
import edu.umn.msi.cagrid.introduce.interfaces.spring.SpringBeanConfiguration;
import edu.umn.msi.cagrid.introduce.interfaces.spring.SpringConfiguration;
import edu.umn.msi.cagrid.introduce.interfaces.spring.ServiceImplProcessor;
import junit.framework.TestCase;

import static edu.umn.msi.cagrid.introduce.interfaces.spring.Constants.*;

public class SpringServiceImplProcessorTestCase extends TestCase {
  public void test() throws Exception {
    ServiceImplProcessor processor;
    
    StringBuffer firstSource = new StringBuffer(SourceProvider.getSpringFirstTestContents());
    processor = new ServiceImplProcessor(firstSource, "SpringTest", "SpringTest",  new SpringConfiguration());
    processor.execute();
    assertTrue(StringBufferUtils.countOccurrences(firstSource, INIT_METHOD_NAME) == 2); // Call and declaration
    assertTrue(StringBufferUtils.countOccurrences(firstSource, SPRING_EXTENSION_ANNOTATION) == 1); // init method
    
    StringBuffer emptySource = new StringBuffer(SourceProvider.getSpringEmptyTestContents());
    processor = new ServiceImplProcessor(emptySource, "SpringTest", "SpringTest", new SpringConfiguration());
    processor.execute();
    assertTrue(StringBufferUtils.countOccurrences(emptySource, INIT_METHOD_NAME) == 2); // Call and declaration
    assertTrue(StringBufferUtils.countOccurrences(emptySource, SPRING_EXTENSION_ANNOTATION) == 1); // init method
    
    SpringConfiguration config = new SpringConfiguration();
    SpringBeanConfiguration bean = new SpringBeanConfiguration();
    bean.setBeanId("beanId");
    bean.setServiceName("SpringTest");
    bean.setFieldClass("java.lang.Object");
    bean.setFieldName("testBean");
    bean.getInterfaces().add("edu.umn.msi.cagrid.introduce.interfaces.TestInterface");
    config.addBean(bean);
    
    emptySource = new StringBuffer(SourceProvider.getSpringEmptyTestContents());
    processor = new ServiceImplProcessor(emptySource, "SpringTest", "SpringTest", config);
    processor.execute();
    assertTrue(StringBufferUtils.countOccurrences(emptySource, INIT_METHOD_NAME) == 2); // Call and declaration
    assertTrue(StringBufferUtils.countOccurrences(emptySource, SPRING_EXTENSION_ANNOTATION) == 3); // init method and 1 bean
    assertTrue(StringBufferUtils.countMatches(emptySource, "java.lang.Object\\s+testBean\\s*;") == 1);
    assertTrue(StringBufferUtils.countOccurrences(emptySource, "testBean") >= 2);
    assertTrue(StringBufferUtils.countMatches(emptySource, "getBean\\s*\\(\\s*\"beanId\"\\s*\\)\\s*;") == 1);
    
    
    processor = new ServiceImplProcessor(emptySource, "SpringTest", "SpringTest", config);
    processor.execute();    
    assertTrue(StringBufferUtils.countOccurrences(emptySource, INIT_METHOD_NAME) == 2); // Call and declaration
    assertTrue(StringBufferUtils.countOccurrences(emptySource, SPRING_EXTENSION_ANNOTATION) == 3); // init method and 1 bean
    assertTrue(StringBufferUtils.countOccurrences(emptySource, "java.lang.Object testBean;") == 1);
    assertTrue(StringBufferUtils.countOccurrences(emptySource, "testBean") >= 2);
    assertTrue(StringBufferUtils.countMatches(emptySource, "getBean\\s*\\(\\s*\"beanId\"\\s*\\)\\s*;") == 1);

    SpringBeanConfiguration bean2 = new SpringBeanConfiguration();
    bean2.setBeanId("bean2Id");
    bean2.setServiceName("SpringTest");
    bean2.setFieldClass("java.lang.String");
    bean2.setFieldName("stringBean"); 
    bean2.getInterfaces().add("edu.umn.msi.cagrid.introduce.interfaces.TestInterface2");
    bean2.getInterfaces().add("edu.umn.msi.cagrid.introduce.interfaces.TestInterface3");
    config.addBean(bean2);
    
    SpringBeanConfiguration ignoredBean = new SpringBeanConfiguration();
    ignoredBean.setBeanId("ignoredBean");
    ignoredBean.setServiceName("NotSpringTest");
    ignoredBean.getInterfaces().add("FakeInterface");
    config.addBean(ignoredBean);
    
    emptySource = new StringBuffer(SourceProvider.getSpringEmptyTestContents());
    processor = new ServiceImplProcessor(emptySource, "SpringTest", "SpringTest",  config);
    processor.execute();

    assertTrue(StringBufferUtils.countOccurrences(emptySource, INIT_METHOD_NAME) == 2); // Call and declaration
    assertTrue(StringBufferUtils.countOccurrences(emptySource, SPRING_EXTENSION_ANNOTATION) == 5); // init method and 2 beans
    assertTrue(StringBufferUtils.countMatches(emptySource, "java.lang.Object\\s+testBean\\s*;") == 1);
    assertTrue(StringBufferUtils.countOccurrences(emptySource, "testBean") >= 2);
    assertTrue(StringBufferUtils.countMatches(emptySource, "getBean\\s*\\(\\s*\"beanId\"\\s*\\)\\s*;") == 1);   

    emptySource = new StringBuffer(SourceProvider.getSpringFirstTestContents());
    processor = new ServiceImplProcessor(emptySource, "SpringTest", "SpringMainTest",  config);
    processor.execute();

    assertTrue(StringBufferUtils.countOccurrences(emptySource, INIT_METHOD_NAME) == 0); // no init method, its not the main service
    assertTrue(StringBufferUtils.countOccurrences(emptySource, SPRING_EXTENSION_ANNOTATION) == 4); // 2 beans
    assertTrue(StringBufferUtils.countMatches(emptySource, "java.lang.Object\\s+testBean\\s*;") == 1);
    assertTrue(StringBufferUtils.countOccurrences(emptySource, "testBean") >= 2);
    assertTrue(StringBufferUtils.countMatches(emptySource, "getBean\\s*\\(\\s*\"beanId\"\\s*\\)\\s*;") == 1);   

  
  }
  
  
}
