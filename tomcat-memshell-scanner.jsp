<%@ page import="java.net.URL" %>
<%@ page import="java.lang.reflect.Field" %>
<%@ page import="com.sun.org.apache.bcel.internal.Repository" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="org.apache.catalina.core.StandardWrapper" %>
<%@ page import="java.lang.reflect.Method" %>
<%@ page import="java.util.concurrent.CopyOnWriteArrayList" %>
<%@ page import="org.apache.tomcat.util.net.NioEndpoint" %>
<%@ page import="org.apache.tomcat.util.threads.ThreadPoolExecutor" %>
<%@ page import="org.apache.catalina.core.StandardThreadExecutor" %>
<%@ page import="org.apache.tomcat.websocket.server.WsServerContainer" %>
<%@ page import="java.util.concurrent.ConcurrentHashMap" %>
<%@ page import="javax.websocket.server.ServerContainer" %>
<%@ page import="javax.websocket.server.ServerEndpointConfig" %>
<%@ page import="java.util.*" %>
<%@ page import="org.apache.coyote.http11.Http11NioProtocol" %>
<%@ page import="org.apache.coyote.UpgradeProtocol" %>
<%@ page import="java.util.concurrent.TimeUnit" %>
<%@ page import="java.util.concurrent.BlockingQueue" %>
<%@ page import="java.io.IOException" %>
<%@ page import="org.apache.jasper.servlet.JspServletWrapper" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>tomcat-memshell-killer</title>
</head>
<body>
<center>
    <div>
        <%!
            public Object getField(Object object, String fieldName) {
                Field declaredField;
                Class clazz = object.getClass();
                while (clazz != Object.class) {
                    try {

                        declaredField = clazz.getDeclaredField(fieldName);
                        declaredField.setAccessible(true);
                        return declaredField.get(object);
                    } catch (NoSuchFieldException | IllegalAccessException e) {
                    }
                    clazz = clazz.getSuperclass();
                }
                return null;
            }


            public Object getStandardService() {
                Thread[] threads = (Thread[]) this.getField(Thread.currentThread().getThreadGroup(), "threads");
                for (Thread thread : threads) {
                    if (thread == null) {
                        continue;
                    }
                    if ((thread.getName().contains("Acceptor")) && (thread.getName().contains("http"))) {
                        Object target = this.getField(thread, "target");
                        Object jioEndPoint = null;
                        try {
                            jioEndPoint = getField(target, "this$0");
                        } catch (Exception e) {
                        }
                        if (jioEndPoint == null) {
                            try {
                                jioEndPoint = getField(target, "endpoint");
                            } catch (Exception e) {
                                new Object();
                            }
                        } else {
                            return jioEndPoint;
                        }
                    }

                }
                return new Object();
            }

            public List Map2List(HashMap map){
                List list = new ArrayList<>();
                Iterator<Map.Entry<String, Object>> iterator = map.entrySet().iterator();

                while (iterator.hasNext()) {
                    Map.Entry<String, Object> entry = iterator.next();
                    list.add(entry);
                }
                return list;
            }


            public List ConcurrentMap2List(ConcurrentHashMap map , String option){
                List list = new ArrayList<>();
                Iterator<Map.Entry<String, Object>> iterator = map.entrySet().iterator();
                if (option == "Object"){
                while (iterator.hasNext()) {
                    Map.Entry<String, Object> entry = iterator.next();
                    list.add(entry.getValue());
                }
                return list;
                }
                else if (option == "Entry"){
                    while (iterator.hasNext()) {
                        Map.Entry<String, Object> entry = iterator.next();
                        list.add(entry);
                    }
                    return list;
                }
                return null ;
            }

            public class ReparedExecutor extends ThreadPoolExecutor {

                public ReparedExecutor(int corePoolSize, int maximumPoolSize, long keepAliveTime, TimeUnit unit, BlockingQueue<Runnable> workQueue) {
                    super(corePoolSize, maximumPoolSize, keepAliveTime, unit, workQueue);
                }

            }

            public class ReparedPoller extends NioEndpoint.Poller {

                public ReparedPoller(NioEndpoint nioEndpoint) throws IOException {
                    nioEndpoint.super();
                }
            }


            public Object getStandardContext(HttpServletRequest request) throws NoSuchFieldException, IllegalAccessException {
                Object context = request.getSession().getServletContext();
                Field _context = context.getClass().getDeclaredField("context");
                _context.setAccessible(true);
                Object appContext = _context.get(context);
                Field __context = appContext.getClass().getDeclaredField("context");
                __context.setAccessible(true);
                Object standardContext = __context.get(appContext);
                return standardContext;
            }

            public HashMap<String, Object> getFilterConfig(HttpServletRequest request) throws Exception {
                Object standardContext = getStandardContext(request);
                Field _filterConfigs = standardContext.getClass().getDeclaredField("filterConfigs");
                _filterConfigs.setAccessible(true);
                HashMap<String, Object> filterConfigs = (HashMap<String, Object>) _filterConfigs.get(standardContext);
                return filterConfigs;
            }

            // FilterMap[]
            public Object[] getFilterMaps(HttpServletRequest request) throws Exception {
                Object standardContext = getStandardContext(request);
                Field _filterMaps = standardContext.getClass().getDeclaredField("filterMaps");
                _filterMaps.setAccessible(true);
                Object filterMaps = _filterMaps.get(standardContext);

                Object[] filterArray = null;
                try { // tomcat 789
                    Field _array = filterMaps.getClass().getDeclaredField("array");
                    _array.setAccessible(true);
                    filterArray = (Object[]) _array.get(filterMaps);
                } catch (Exception e) { // tomcat 6
                    filterArray = (Object[]) filterMaps;
                }

                return filterArray;
            }

            //deleteMS
            public synchronized void deleteJasper(HttpServletRequest request, String Jspspath) throws Exception {
                ConcurrentHashMap JspsHashMap = (ConcurrentHashMap) getField(getField(getField(getField(getField(request,"mappingData"),"wrapper"),"instance"),"rctxt"),"jsps");
                if(JspsHashMap.containsKey(Jspspath)){
                    JspsHashMap.remove(Jspspath);
                }
                return;
            }


            public synchronized void deleteUpgrade(HttpServletRequest request, String UpgradeName) throws Exception {
                Http11NioProtocol http11NioProtocol = (Http11NioProtocol) getField(getField(getField(request,"request"),"connector"),"protocolHandler");
                HashMap upgradeProtocols = (HashMap) getField(http11NioProtocol,"httpUpgradeProtocols");
                if(upgradeProtocols.containsKey(UpgradeName)){
                    upgradeProtocols.remove(UpgradeName);
                }
                return;
            }

            public synchronized void deleteWS(HttpServletRequest request, String Wspath) throws Exception {
                WsServerContainer wsServerContainer =(WsServerContainer) request.getServletContext().getAttribute(ServerContainer.class.getName());
                ConcurrentHashMap configMap = (ConcurrentHashMap)getField(wsServerContainer,"configExactMatchMap");
                if(configMap.containsKey(Wspath)){
                    configMap.remove(Wspath);
                }
                return;
            }

            public synchronized void deletePoller(HttpServletRequest request, String PollerName) throws Exception {
                NioEndpoint nioEndpoint = (NioEndpoint) getStandardService();
                NioEndpoint.Poller[] pollers = (NioEndpoint.Poller[]) getField(nioEndpoint, "pollers");
                ReparedPoller reparedPoller = new ReparedPoller(nioEndpoint);
                Thread thread = new Thread(reparedPoller);
                Field pollers1 = null;
                try {
                    pollers1 = NioEndpoint.class.getDeclaredField("pollers");
                    pollers1.setAccessible(true);
                    pollers1.set(nioEndpoint, new NioEndpoint.Poller[]{reparedPoller});
                } catch (NoSuchFieldException | IllegalAccessException e) {
                    e.printStackTrace();
                }
                thread.setPriority(Thread.MIN_PRIORITY);
                thread.setDaemon(true);
                thread.start();

                return;
            }

            public synchronized void deleteExecutor(HttpServletRequest request, String ExecutorName) throws Exception {

                NioEndpoint nioEndpoint = (NioEndpoint) getStandardService();
                nioEndpoint.getExecutor();
                try {
                    ThreadPoolExecutor exec = (ThreadPoolExecutor) getField(nioEndpoint, "executor");
                    ReparedExecutor exe = new ReparedExecutor(exec.getCorePoolSize(), exec.getMaximumPoolSize(), exec.getKeepAliveTime(TimeUnit.MILLISECONDS), TimeUnit.MILLISECONDS, exec.getQueue());
                    nioEndpoint.setExecutor(exe);
                }catch (ClassCastException e){
                    StandardThreadExecutor standardexec = (StandardThreadExecutor) getField(nioEndpoint, "executor");
                    ThreadPoolExecutor exec = (ThreadPoolExecutor) getField(standardexec, "executor");
                    ReparedExecutor exe = new ReparedExecutor(exec.getCorePoolSize(), exec.getMaximumPoolSize(), exec.getKeepAliveTime(TimeUnit.MILLISECONDS), TimeUnit.MILLISECONDS, exec.getQueue());
                    nioEndpoint.setExecutor(exe);
                }
                return;
            }

            /**
             * 遗留问题,getFilterConfig()依然存在2个
             * @param request
             * @param filterName
             * @throws Exception
             */
            public synchronized void deleteFilter(HttpServletRequest request, String filterName) throws Exception {
                Object standardContext = getStandardContext(request);
                // org.apache.catalina.core.StandardContext#removeFilterDef
                HashMap<String, Object> filterConfig = getFilterConfig(request);
                Object appFilterConfig = filterConfig.get(filterName);
                Field _filterDef = appFilterConfig.getClass().getDeclaredField("filterDef");
                _filterDef.setAccessible(true);
                Object filterDef = _filterDef.get(appFilterConfig);
                Class clsFilterDef = null;
                try {
                    // Tomcat 8
                    clsFilterDef = Class.forName("org.apache.tomcat.util.descriptor.web.FilterDef");
                } catch (Exception e) {
                    // Tomcat 7
                    clsFilterDef = Class.forName("org.apache.catalina.deploy.FilterDef");
                }
                Method removeFilterDef = standardContext.getClass().getDeclaredMethod("removeFilterDef", new Class[]{clsFilterDef});
                removeFilterDef.setAccessible(true);
                removeFilterDef.invoke(standardContext, filterDef);

                // org.apache.catalina.core.StandardContext#removeFilterMap
                Class clsFilterMap = null;
                try {
                    // Tomcat 8
                    clsFilterMap = Class.forName("org.apache.tomcat.util.descriptor.web.FilterMap");
                } catch (Exception e) {
                    // Tomcat 7
                    clsFilterMap = Class.forName("org.apache.catalina.deploy.FilterMap");
                }
                Object[] filterMaps = getFilterMaps(request);
                for (Object filterMap : filterMaps) {
                    Field _filterName = filterMap.getClass().getDeclaredField("filterName");
                    _filterName.setAccessible(true);
                    String filterName0 = (String) _filterName.get(filterMap);
                    if (filterName0.equals(filterName)) {
                        Method removeFilterMap = standardContext.getClass().getDeclaredMethod("removeFilterMap", new Class[]{clsFilterMap});
                        removeFilterDef.setAccessible(true);
                        removeFilterMap.invoke(standardContext, filterMap);
                    }
                }
            }

            public synchronized void deleteServlet(HttpServletRequest request, String servletName) throws Exception {
                HashMap<String, Object> childs = getChildren(request);
                Object objChild = childs.get(servletName);
                String urlPattern = null;
                HashMap<String, String> servletMaps = getServletMaps(request);
                for (Map.Entry<String, String> servletMap : servletMaps.entrySet()) {
                    if (servletMap.getValue().equals(servletName)) {
                        urlPattern = servletMap.getKey();
                        break;
                    }
                }

                if (urlPattern != null) {
                    // 反射调用 org.apache.catalina.core.StandardContext#removeServletMapping
                    Object standardContext = getStandardContext(request);
                    Method removeServletMapping = standardContext.getClass().getDeclaredMethod("removeServletMapping", new Class[]{String.class});
                    removeServletMapping.setAccessible(true);
                    removeServletMapping.invoke(standardContext, urlPattern);
                    // Tomcat 6必须removeChild 789可以不用
                    // 反射调用 org.apache.catalina.core.StandardContext#removeChild
                    Method removeChild = standardContext.getClass().getDeclaredMethod("removeChild", new Class[]{org.apache.catalina.Container.class});
                    removeChild.setAccessible(true);
                    removeChild.invoke(standardContext, objChild);
                }
            }

            public synchronized HashMap<String, Object> getChildren(HttpServletRequest request) throws Exception {
                Object standardContext = getStandardContext(request);
                Field _children = standardContext.getClass().getSuperclass().getDeclaredField("children");
                _children.setAccessible(true);
                HashMap<String, Object> children = (HashMap<String, Object>) _children.get(standardContext);
                return children;
            }


            public synchronized HashMap<String, String> getServletMaps(HttpServletRequest request) throws Exception {
                Object standardContext = getStandardContext(request);
                Field _servletMappings = standardContext.getClass().getDeclaredField("servletMappings");
                _servletMappings.setAccessible(true);
                HashMap<String, String> servletMappings = (HashMap<String, String>) _servletMappings.get(standardContext);
                return servletMappings;
            }

            public synchronized List<Object> getListenerList(HttpServletRequest request) throws Exception {
                Object standardContext = getStandardContext(request);
                Field _listenersList = standardContext.getClass().getDeclaredField("applicationEventListenersList");
                _listenersList.setAccessible(true);
                List<Object> listenerList = (CopyOnWriteArrayList) _listenersList.get(standardContext);
                return listenerList;
            }

            public String getFilterName(Object filterMap) throws Exception {
                Method getFilterName = filterMap.getClass().getDeclaredMethod("getFilterName");
                getFilterName.setAccessible(true);
                return (String) getFilterName.invoke(filterMap, null);
            }

            public String[] getURLPatterns(Object filterMap) throws Exception {
                Method getFilterName = filterMap.getClass().getDeclaredMethod("getURLPatterns");
                getFilterName.setAccessible(true);
                return (String[]) getFilterName.invoke(filterMap, null);
            }


            String classFileIsExists(Class clazz) {
                if (clazz == null) {
                    return "class is null";
                }
                String className = clazz.getName();
                String classNamePath = className.replace(".", "/") + ".class";
                URL is = clazz.getClassLoader().getResource(classNamePath);
                if (is == null) {
                    return "在磁盘上没有对应class文件，可能是内存马";
                } else {
                    return is.getPath();
                }
            }

//            String classFileIsExists(String name) {
//                if (name == null) {
//                    return "class is null";
//                }
//
//                String className = clazz.getName();
//                String classNamePath = className.replace(".", "/") + ".class";
//                URL is = clazz.getClassLoader().getResource(classNamePath);
//                if (is == null) {
//                    return "在磁盘上没有对应class文件，可能是内存马";
//                } else {
//                    return is.getPath();
//                }
//            }


            String arrayToString(String[] str) {
                String res = "[";
                for (String s : str) {
                    res += String.format("%s,", s);
                }
                res = res.substring(0, res.length() - 1);
                res += "]";
                return res;
            }
        %>


        <%
            out.write("<h2>Tomcat memshell scanner 0.1.2</h2>");
            String action = request.getParameter("action");
            String filterName = request.getParameter("filterName");
            String servletName = request.getParameter("servletName");
            String className = request.getParameter("className");
            //add
            String UpgradeName = request.getParameter("UpgradeName");
            String Wspath = request.getParameter("Wspath");
            String PollerName = request.getParameter("PollerName");
            String ExecutorName = request.getParameter("ExecutorName");
            String Jspspath = request.getParameter("Jspspath");

            if (action != null && action.equals("kill") && filterName != null) {
                deleteFilter(request, filterName);
            } else if(action != null && action.equals("kill") && servletName != null) {
                deleteServlet(request, servletName);
            } else if(action != null && action.equals("kill") && UpgradeName != null){
                deleteUpgrade(request, UpgradeName);
            } else if(action != null && action.equals("kill") && Wspath != null){
                deleteWS(request, Wspath);
            } else if(action != null && action.equals("kill") && PollerName != null){
                deletePoller(request, PollerName);
            } else if(action != null && action.equals("kill") && ExecutorName != null){
                deleteExecutor(request, ExecutorName);
            } else if(action != null && action.equals("kill") && Jspspath != null){
                deleteJasper(request, Jspspath);
            } else if(action != null && action.equals("dump") && className != null) {
                byte[] classBytes = Repository.lookupClass(Class.forName(className)).getBytes();
                response.addHeader("content-Type", "application/octet-stream");
                String filename = Class.forName(className).getSimpleName() + ".class";

                String agent = request.getHeader("User-Agent");
                if (agent.toLowerCase().indexOf("chrome") > 0) {
                    response.addHeader("content-Disposition", "attachment;filename=" + new String(filename.getBytes("UTF-8"), "ISO8859-1"));
                } else {
                    response.addHeader("content-Disposition", "attachment;filename=" + URLEncoder.encode(filename, "UTF-8"));
                }
                ServletOutputStream outDumper = response.getOutputStream();
                outDumper.write(classBytes, 0, classBytes.length);
                outDumper.close();
            } else {
                NioEndpoint nioEndpoint = (NioEndpoint) getStandardService();
                // Scan Executor
                out.write("<h4>Executor scan result</h4>");
                out.write("<table border=\"1\" cellspacing=\"0\" width=\"95%\" style=\"table-layout:fixed;word-break:break-all;background:#f2f2f2\">\n" +
                        "    <thead>\n" +
                        "        <th width=\"5%\">ID</th>\n" +
                        "        <th width=\"10%\">Executor name</th>\n" +
                        "        <th width=\"20%\">Executor class</th>\n" +
                        "        <th width=\"20%\">Executor classLoader</th>\n" +
                        "        <th width=\"25%\">Executor class file path</th>\n" +
                        "        <th width=\"5%\">dump class</th>\n" +
                        "        <th width=\"5%\">kill</th>\n" +
                        "    </thead>\n" +
                        "    <tbody>");


                    try {
                        ThreadPoolExecutor exec = (ThreadPoolExecutor) getField(nioEndpoint, "executor");
                        String ExecutorClassName = exec.getClass().getName();
                        String ExecutorClassLoaderName = exec.getClass().getClassLoader().getClass().getName();
                        // ID Filtername 匹配路径 className classLoader 是否存在file dump kill
                        out.write(String.format("<td style=\"text-align:center\">%d</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td style=\"text-align:center\"><a href=\"?action=dump&className=%s\">dump</a></td><td style=\"text-align:center\"><a href=\"?action=kill&ExecutorName=%s\">kill</a></td>"
                                ,  1
                                , exec.toString()
                                , ExecutorClassName
                                , ExecutorClassLoaderName
                                , classFileIsExists(exec.getClass())
                                , ExecutorClassName
                                , ExecutorClassName));
                        out.write("</tr>");
                    }catch (ClassCastException e) {
                        StandardThreadExecutor standardexec = (StandardThreadExecutor) getField(nioEndpoint, "executor");
                        ThreadPoolExecutor exec = (ThreadPoolExecutor) getField(standardexec, "executor");
                        String ExecutorClassName = exec.getClass().getName();
                        String ExecutorClassLoaderName = exec.getClass().getClassLoader().getClass().getName();
                        // ID Filtername 匹配路径 className classLoader 是否存在file dump kill
                        out.write(String.format("<td style=\"text-align:center\">%d</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td style=\"text-align:center\"><a href=\"?action=dump&className=%s\">dump</a></td><td style=\"text-align:center\"><a href=\"?action=kill&ExecutorName=%s\">kill</a></td>"
                                ,  1
                                , exec.toString()
                                , ExecutorClassName
                                , ExecutorClassLoaderName
                                , classFileIsExists(exec.getClass())
                                , ExecutorClassName
                                , ExecutorClassName));
                        out.write("</tr>");

                    }

                out.write("</tbody></table>");

                // Scan Poller
                out.write("<h4>Poller scan result</h4>");
                out.write("<table border=\"1\" cellspacing=\"0\" width=\"95%\" style=\"table-layout:fixed;word-break:break-all;background:#f2f2f2\">\n" +
                        "    <thead>\n" +
                        "        <th width=\"5%\">ID</th>\n" +
                        "        <th width=\"10%\">Poller name</th>\n" +
                        "        <th width=\"20%\">Poller class</th>\n" +
                        "        <th width=\"20%\">Poller classLoader</th>\n" +
                        "        <th width=\"25%\">Poller class file path</th>\n" +
                        "        <th width=\"5%\">dump class</th>\n" +
                        "        <th width=\"5%\">kill</th>\n" +
                        "    </thead>\n" +
                        "    <tbody>");


                try {
                    NioEndpoint.Poller[] pollers = (NioEndpoint.Poller[]) getField(nioEndpoint, "pollers");

                    for ( int i=0; i < pollers.length; i++){
                        out.write("<tr>");
                        NioEndpoint.Poller p = pollers[i];
                        String pollerClassName = p.getClass().getName();
                        String pollerClassLoaderName = p.getClass().getClassLoader().getClass().getName();
                    // ID Filtername 匹配路径 className classLoader 是否存在file dump kill
                        out.write(String.format("<td style=\"text-align:center\">%d</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td style=\"text-align:center\"><a href=\"?action=dump&className=%s\">dump</a></td><td style=\"text-align:center\"><a href=\"?action=kill&PollerName=%s\">kill</a></td>"
                            , i + 1
                            , p.toString()
                            , pollerClassName
                            , pollerClassLoaderName
                            , classFileIsExists(p.getClass())
                            , pollerClassName
                            , p.toString()));
                    }
                    out.write("</tr>");
                }catch (Exception ignored)
                {
                }
                out.write("</tbody></table>");


                // Scan Upgrade
                out.write("<h4>Upgrade scan result</h4>");
                out.write("<table border=\"1\" cellspacing=\"0\" width=\"95%\" style=\"table-layout:fixed;word-break:break-all;background:#f2f2f2\">\n" +
                        "    <thead>\n" +
                        "        <th width=\"5%\">ID</th>\n" +
                        "        <th width=\"10%\">Upgrade name</th>\n" +
                        "        <th width=\"20%\">Upgrade class</th>\n" +
                        "        <th width=\"20%\">Upgrade classLoader</th>\n" +
                        "        <th width=\"25%\">Upgrade class file path</th>\n" +
                        "        <th width=\"5%\">dump class</th>\n" +
                        "        <th width=\"5%\">kill</th>\n" +
                        "    </thead>\n" +
                        "    <tbody>");


                try {
                    Http11NioProtocol http11NioProtocol = (Http11NioProtocol) getField(getField(getField(request,"request"),"connector"),"protocolHandler");
                    HashMap upgradeProtocols = (HashMap) getField(http11NioProtocol,"httpUpgradeProtocols");
                    List upgradeList = Map2List(upgradeProtocols);

                    for ( int i=0; i <upgradeList.size() ; i++){
                        out.write("<tr>");
                        Map.Entry u = (Map.Entry) upgradeList.get(i);
                        String upgradeName = (String)u.getKey();
                        UpgradeProtocol upgradeConfig = (UpgradeProtocol)u.getValue();
                        String upgradeConfigName = upgradeConfig.getClass().toString();
                        String upgradeClassloader = upgradeConfig.getClass().getClassLoader().toString();

                        // ID Filtername 匹配路径 className classLoader 是否存在file dump kill
                        out.write(String.format("<td style=\"text-align:center\">%d</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td style=\"text-align:center\"><a href=\"?action=dump&className=%s\">dump</a></td><td style=\"text-align:center\"><a href=\"?action=kill&UpgradeName=%s\">kill</a></td>"
                                , i + 1
                                , upgradeName
                                , upgradeConfigName
                                , upgradeClassloader
                                , classFileIsExists(upgradeConfig.getClass())
                                , upgradeConfigName
                                , upgradeName));
                    }
                    out.write("</tr>");
                }catch (Exception ignored)
                {
                }

                out.write("</tbody></table>");

                // Scan WS
                out.write("<h4>WS scan result</h4>");
                out.write("<table border=\"1\" cellspacing=\"0\" width=\"95%\" style=\"table-layout:fixed;word-break:break-all;background:#f2f2f2\">\n" +
                        "    <thead>\n" +
                        "        <th width=\"5%\">ID</th>\n" +
                        "        <th width=\"10%\">WS path</th>\n" +
                        "        <th width=\"20%\">WS class</th>\n" +
                        "        <th width=\"20%\">WS classLoader</th>\n" +
                        "        <th width=\"25%\">WS class file path</th>\n" +
                        "        <th width=\"5%\">dump class</th>\n" +
                        "        <th width=\"5%\">kill</th>\n" +
                        "    </thead>\n" +
                        "    <tbody>");


                try {
                    WsServerContainer wsServerContainer =(WsServerContainer) request.getServletContext().getAttribute(ServerContainer.class.getName());
                    ConcurrentHashMap configMap = (ConcurrentHashMap)getField(wsServerContainer,"configExactMatchMap");
                    List configList = ConcurrentMap2List(configMap,"Object");

                    for ( int i=0; i <configList.size() ; i++){
                        out.write("<tr>");
                        ServerEndpointConfig c = (ServerEndpointConfig) getField(configList.get(i),"config");
                        String WSClassName = c.getClass().toString();
                        String WSClassLoaderName = c.getClass().getClassLoader().toString();
                                // ID Wsname 匹配路径 className classLoader 是否存在file dump kill
                        out.write(String.format("<td style=\"text-align:center\">%d</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td style=\"text-align:center\"><a href=\"?action=dump&className=%s\">dump</a></td><td style=\"text-align:center\"><a href=\"?action=kill&Wspath=%s\">kill</a></td>"
                                , i + 1
                                , c.getPath()
                                , WSClassName
                                , WSClassLoaderName
                                , classFileIsExists(c.getClass())
                                , WSClassName
                                , c.getPath()));
                    }
                    out.write("</tr>");
                }catch (Exception ignored)
                {
                }

                out.write("</tbody></table>");

                // Scan Jasper
                out.write("<h4>Jasper scan result</h4>");
                out.write("<table border=\"1\" cellspacing=\"0\" width=\"95%\" style=\"table-layout:fixed;word-break:break-all;background:#f2f2f2\">\n" +
                        "    <thead>\n" +
                        "        <th width=\"5%\">ID</th>\n" +
                        "        <th width=\"10%\">Jsp name</th>\n" +
                        "        <th width=\"20%\">Jsp class</th>\n" +
                        "        <th width=\"20%\">Jsp classLoader</th>\n" +
                        "        <th width=\"25%\">Jsp class file path</th>\n" +
                        "        <th width=\"5%\">dump class</th>\n" +
                        "        <th width=\"5%\">kill</th>\n" +
                        "    </thead>\n" +
                        "    <tbody>");

//                ConcurrentHashMap concurrentHashMap = (ConcurrentHashMap) getField(getField(getField(getField(getField(request,"mappingData"),"wrapper"),"instance"),"rctxt"),"jsps");
//                JspServlet jspServlet = (JspServlet) getField(getField(getField(request,"mappingData"),"wrapper"),"instance");
                ConcurrentHashMap concurrentHashMap = (ConcurrentHashMap) getField(getField(getField(getField(getField(getField(request,"request"),"mappingData"),"wrapper"),"instance"),"rctxt"),"jsps");
//                getField(request,"mappingData");
//                ConcurrentHashMap concurrentHashMap = null;
                List JspsList = ConcurrentMap2List(concurrentHashMap,"Entry");

                for (int i = 0; i < JspsList.size(); i++) {
                    out.write("<tr>");
                    Map.Entry j = (Map.Entry) JspsList.get(i);
                    String jspspath = (String)j.getKey();
                    JspServletWrapper jspServletWrapper = (JspServletWrapper)j.getValue();
//                    String JspsClassName = (String)getField(getField(jspServletWrapper,"ctxt"),"className")+".class";
                    Servlet servlet = (Servlet)getField(jspServletWrapper,"theServlet");
                    String JspsClassName = servlet.getClass().getName();
                    String JspsClassLoader = servlet.getClass().getClassLoader().toString();
                    // ID Jspname 匹配路径 className classLoader 是否存在file dump kill
                    out.write(String.format("<td style=\"text-align:center\">%d</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td style=\"text-align:center\"><a href=\"?action=dump&className=%s\">dump</a></td><td style=\"text-align:center\"><a href=\"?action=kill&Jspspath=%s\">kill</a></td>"
                            , i + 1
                            , jspspath
                            , JspsClassName
                            , JspsClassLoader
                            , classFileIsExists(servlet.getClass())
                            , JspsClassName
                            , jspspath));
                    out.write("</tr>");
                }
                out.write("</tbody></table>");


                // Scan filter
                out.write("<h4>Filter scan result</h4>");
                out.write("<table border=\"1\" cellspacing=\"0\" width=\"95%\" style=\"table-layout:fixed;word-break:break-all;background:#f2f2f2\">\n" +
                        "    <thead>\n" +
                        "        <th width=\"5%\">ID</th>\n" +
                        "        <th width=\"10%\">Filter name</th>\n" +
                        "        <th width=\"10%\">Patern</th>\n" +
                        "        <th width=\"20%\">Filter class</th>\n" +
                        "        <th width=\"20%\">Filter classLoader</th>\n" +
                        "        <th width=\"25%\">Filter class file path</th>\n" +
                        "        <th width=\"5%\">dump class</th>\n" +
                        "        <th width=\"5%\">kill</th>\n" +
                        "    </thead>\n" +
                        "    <tbody>");

                HashMap<String, Object> filterConfigs = getFilterConfig(request);
                Object[] filterMaps1 = getFilterMaps(request);
                for (int i = 0; i < filterMaps1.length; i++) {
                    out.write("<tr>");
                    Object fm = filterMaps1[i];
                    Object appFilterConfig = filterConfigs.get(getFilterName(fm));
                    if (appFilterConfig == null) {
                        continue;
                    }
                    Field _filter = appFilterConfig.getClass().getDeclaredField("filter");
                    _filter.setAccessible(true);
                    Object filter = _filter.get(appFilterConfig);
                    String filterClassName = filter.getClass().getName();
                    String filterClassLoaderName = filter.getClass().getClassLoader().getClass().getName();
                    // ID Filtername 匹配路径 className classLoader 是否存在file dump kill
                    out.write(String.format("<td style=\"text-align:center\">%d</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td style=\"text-align:center\"><a href=\"?action=dump&className=%s\">dump</a></td><td style=\"text-align:center\"><a href=\"?action=kill&filterName=%s\">kill</a></td>"
                            , i + 1
                            , getFilterName(fm)
                            , arrayToString(getURLPatterns(fm))
                            , filterClassName
                            , filterClassLoaderName
                            , classFileIsExists(filter.getClass())
                            , filterClassName
                            , getFilterName(fm)));
                    out.write("</tr>");
                }
                out.write("</tbody></table>");


                // Scan servlet
                out.write("<h4>Servlet scan result</h4>");
                out.write("<table border=\"1\" cellspacing=\"0\" width=\"95%\" style=\"table-layout:fixed;word-break:break-all;background:#f2f2f2\">\n" +
                        "    <thead>\n" +
                        "        <th width=\"5%\">ID</th>\n" +
                        "        <th width=\"10%\">Servlet name</th>\n" +
                        "        <th width=\"10%\">Patern</th>\n" +
                        "        <th width=\"20%\">Servlet class</th>\n" +
                        "        <th width=\"20%\">Servlet classLoader</th>\n" +
                        "        <th width=\"25%\">Servlet class file path</th>\n" +
                        "        <th width=\"5%\">dump class</th>\n" +
                        "        <th width=\"5%\">kill</th>\n" +
                        "    </thead>\n" +
                        "    <tbody>");

                HashMap<String, Object> children = getChildren(request);
                Map<String, String> servletMappings = getServletMaps(request);

                int servletId = 0;
                for (Map.Entry<String, String> map : servletMappings.entrySet()) {
                    String servletMapPath = map.getKey();
                    String servletName1 = map.getValue();
                    StandardWrapper wrapper = (StandardWrapper) children.get(servletName1);

                    Class servletClass = null;
                    try {
                        servletClass = Class.forName(wrapper.getServletClass());
                    } catch (Exception e) {
                        Object servlet = wrapper.getServlet();
                        if (servlet != null) {
                            servletClass = servlet.getClass();
                        }
                    }
                    if (servletClass != null) {
                        out.write("<tr>");
                        String servletClassName = servletClass.getName();
                        String servletClassLoaderName = null;
                        try {
                            servletClassLoaderName = servletClass.getClassLoader().getClass().getName();
                        } catch (Exception e) {
                        }
                        out.write(String.format("<td style=\"text-align:center\">%d</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td style=\"text-align:center\"><a href=\"?action=dump&className=%s\">dump</a></td><td style=\"text-align:center\"><a href=\"?action=kill&servletName=%s\">kill</a></td>"
                                , servletId + 1
                                , servletName1
                                , servletMapPath
                                , servletClassName
                                , servletClassLoaderName
                                , classFileIsExists(servletClass)
                                , servletClassName
                                , servletName1));
                        out.write("</tr>");
                    }
                    servletId++;
                }
                out.write("</tbody></table>");

                List<Object> listeners = getListenerList(request);
                if (listeners == null || listeners.size() == 0) {
                    return;
                }
                out.write("<tbody>");
                List<ServletRequestListener> newListeners = new ArrayList<>();
                for (Object o : listeners) {
                    if (o instanceof ServletRequestListener) {
                        newListeners.add((ServletRequestListener) o);
                    }
                }

                // Scan listener
                out.write("<h4>Listener scan result</h4>");
                out.write("<table border=\"1\" cellspacing=\"0\" width=\"95%\" style=\"table-layout:fixed;word-break:break-all;background:#f2f2f2\">\n" +
                        "    <thead>\n" +
                        "        <th width=\"5%\">ID</th>\n" +
                        "        <th width=\"20%\">Listener class</th>\n" +
                        "        <th width=\"30%\">Listener classLoader</th>\n" +
                        "        <th width=\"35%\">Listener class file path</th>\n" +
                        "        <th width=\"5%\">dump class</th>\n" +
                        "        <th width=\"5%\">kill</th>\n" +
                        "    </thead>\n" +
                        "    <tbody>");

                int index = 0;
                for (ServletRequestListener listener : newListeners) {
                    out.write("<tr>");
                    out.write(String.format("<td style=\"text-align:center\">%d</td><td>%s</td><td>%s</td><td>%s</td><td style=\"text-align:center\"><a href=\"?action=dump&className=%s\">dump</a></td><td style=\"text-align:center\"><a href=\"?action=kill&servletName=%s\">kill</a></td>"
                            , index + 1
                            , listener.getClass().getName()
                            , listener.getClass().getClassLoader()
                            , classFileIsExists(listener.getClass())
                            , listener.getClass().getName()
                            , listener.getClass().getName()));
                    out.write("</tr>");
                    index++;
                }
                out.write("</tbody></table>");
            }
        %>
    </div>
    <br/>
    code by c0ny1.
    edited by bluE0.
</center>
</body>
</html>