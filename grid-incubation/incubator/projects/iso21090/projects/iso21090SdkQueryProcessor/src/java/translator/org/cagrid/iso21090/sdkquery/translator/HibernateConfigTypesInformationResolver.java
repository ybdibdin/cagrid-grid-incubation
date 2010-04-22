package org.cagrid.iso21090.sdkquery.translator;

import gov.nih.nci.cacoresdk.domain.other.datatype.EnDataType;

import java.io.InputStream;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.hibernate.cfg.Configuration;
import org.hibernate.mapping.Collection;
import org.hibernate.mapping.Component;
import org.hibernate.mapping.OneToMany;
import org.hibernate.mapping.PersistentClass;
import org.hibernate.mapping.Property;
import org.hibernate.mapping.RootClass;
import org.hibernate.mapping.Subclass;
import org.hibernate.mapping.ToOne;
import org.hibernate.mapping.Value;

public class HibernateConfigTypesInformationResolver implements TypesInformationResolver {
    
    private Configuration configuration = null;
    private Map<String, Boolean> subclasses = null;
    private Map<String, Object> discriminators = null;
    private Map<String, Class<?>> fieldDataTypes = null;
    private Map<String, String> roleNames = null;
    private boolean reflectionFallback = false;
    
    public HibernateConfigTypesInformationResolver(Configuration hibernateConfig, boolean reflectionFallback) {
        this.configuration = hibernateConfig;
        this.subclasses = new HashMap<String, Boolean>();
        this.discriminators = new HashMap<String, Object>();
        this.fieldDataTypes = new HashMap<String, Class<?>>();
        this.roleNames = new HashMap<String, String>();
        this.reflectionFallback = reflectionFallback;
    }
    

    public boolean classHasSubclasses(String classname) throws TypesInformationException {
        Boolean hasSubclasses = subclasses.get(classname);
        if (hasSubclasses == null) {
            PersistentClass clazz = configuration.getClassMapping(classname);
            if (clazz != null) {
                hasSubclasses = Boolean.valueOf(clazz.hasSubclasses());
                subclasses.put(classname, hasSubclasses);
            } else {
                throw new TypesInformationException("Class " + classname + " not found in configuration");
            }
        }
        return hasSubclasses.booleanValue();
    }


    public Object getClassDiscriminatorValue(String classname) throws TypesInformationException {
        Object identifier = discriminators.get(classname);
        if (identifier == null) {
            PersistentClass clazz = configuration.getClassMapping(classname);
            if (clazz != null) {
                if (clazz instanceof Subclass) {
                    Subclass sub = (Subclass) clazz;
                    if (sub.isJoinedSubclass()) {
                        identifier = Integer.valueOf(sub.getSubclassId());
                    } else {
                        identifier = getShortClassName(classname);
                    }
                } else if (clazz instanceof RootClass) {
                    RootClass root = (RootClass) clazz;
                    if (root.getDiscriminator() == null) {
                        identifier = Integer.valueOf(root.getSubclassId());
                    } else {
                        identifier = getShortClassName(classname);
                    }
                }
            } else {
                throw new TypesInformationException("Class " + classname + " not found in hibernate configuration");
            }
            discriminators.put(classname, identifier);
        }
        return identifier;
    }

    
    public Class<?> getJavaDataType(String classname, String field) throws TypesInformationException {
        String fqName = classname + "." + field;
        Class<?> type = fieldDataTypes.get(fqName);
        if (type == null) {
            PersistentClass clazz = configuration.getClassMapping(classname);
            if (clazz != null) {
                // TODO: test that this barks up the inheritance tree for properties
                Property property = clazz.getRecursiveProperty(field);
                if (property != null) {
                    type = property.getType().getReturnedClass();
                } else {
                    throw new TypesInformationException("Field " + fqName + " not found in hibernate configuration");
                }
            } else if (reflectionFallback) {
                try {
                    Class<?> javaClass = Class.forName(classname);
                    Field javaField = javaClass.getDeclaredField(field);
                    type = javaField.getType();
                } catch (ClassNotFoundException ex) {
                    throw new TypesInformationException("Class " + classname + " not found in hibernate configuration or via reflection");
                } catch (NoSuchFieldException ex) {
                    throw new TypesInformationException("Field " + field + " of class " + classname + " could not be found via reflection");
                }
            } else {
                throw new TypesInformationException("Class " + classname + " not found in hibernate configuration");
            }
            fieldDataTypes.put(fqName, type);
        }
        return type;
    }


    public String getRoleName(String parentClassname, String childClassname) throws TypesInformationException {
        String identifier = getAssociationIdentifier(parentClassname, childClassname);
        String roleName = roleNames.get(identifier);
        if (roleName == null) {
            PersistentClass clazz = configuration.getClassMapping(parentClassname);
            Iterator<?> propertyIter = clazz.getPropertyIterator();
            while (propertyIter.hasNext()) {
                Property prop = (Property) propertyIter.next();
                Value value = prop.getValue();
                String referencedEntity = null;
                if (value instanceof Collection) {
                    Value element = ((Collection) value).getElement();
                    if (element instanceof OneToMany) {
                        referencedEntity = ((OneToMany) element).getReferencedEntityName();
                    } else if (element instanceof ToOne) {
                        referencedEntity = ((ToOne) element).getReferencedEntityName();
                    }
                } else if (value instanceof ToOne) {
                    referencedEntity = ((ToOne) value).getReferencedEntityName();
                }
                if (childClassname.equals(referencedEntity)) {
                    if (roleName != null) {
                        // already found one association, so this is ambiguous
                        throw new TypesInformationException("Association from " + parentClassname + " to " 
                            + childClassname + " is ambiguous.  Please specify a valid role name");
                    }
                    roleName = prop.getName();
                }
            }
        }
        return roleName;
    }
    
    
    public List<String> getInnerComponentNames(String parentClassname, String topLevelComponentName,
        String innerComponentNamePrefix) {
        List<String> names = new ArrayList<String>();
        PersistentClass parent = configuration.getClassMapping(parentClassname);
        Property topLevel = parent.getProperty(topLevelComponentName);
        Component topLevelComponent = (Component) topLevel.getValue();
        Iterator<?> propertyIter = topLevelComponent.getPropertyIterator();
        while (propertyIter.hasNext()) {
            Property prop = (Property) propertyIter.next();
            if (prop.getName().startsWith(innerComponentNamePrefix)) {
                names.add(prop.getName());
            }
        }
        return names;
    }
    
    
    private String getShortClassName(String className) {
        int dotIndex = className.lastIndexOf('.');
        return className.substring(dotIndex + 1);
    }
    
    
    private String getAssociationIdentifier(String parentClassname, String childClassname) {
        return parentClassname + "-->" + childClassname;
    }
    
    
    public static void main(String[] args) {
        try {
            InputStream is = HibernateConfigTypesInformationResolver.class.getResourceAsStream("/hibernate.cfg.xml");
            Configuration config = new Configuration();
            config.addInputStream(is);
            config.buildMappings();
            config.configure();
            
            HibernateConfigTypesInformationResolver resolver = new HibernateConfigTypesInformationResolver(config, true);
            List<String> partNames = resolver.getInnerComponentNames(
                EnDataType.class.getName(), "value1", "part");
            for (String name : partNames) {
                System.out.println(name);
            }
            is.close();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
}