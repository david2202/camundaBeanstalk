<?xml version='1.0' encoding='utf-8'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- Apply updates to the tomcat server.xml -->
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="Server">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="Listener[@className='org.apache.catalina.mbeans.GlobalResourcesLifecycleListener']">
        <xsl:if test="not(../Listener[@className='org.camunda.bpm.container.impl.tomcat.TomcatBpmPlatformBootstrap'])">
            <xsl:call-template name="listener" />
        </xsl:if>
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template match="GlobalNamingResources">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <xsl:if test="not(Resource[@name='jdbc/ProcessEngine'])">
                <xsl:call-template name="resourceProcessEngine" />
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="Resource[@name='jdbc/ProcessEngine']">
        <xsl:call-template name="resourceProcessEngine" />
    </xsl:template>

    <xsl:template name="listener">
        <Listener className="org.camunda.bpm.container.impl.tomcat.TomcatBpmPlatformBootstrap" />
    </xsl:template>

    <xsl:template name="resourceProcessEngine">
        <Resource name="jdbc/ProcessEngine"
                  auth="Container"
                  type="javax.sql.DataSource"
                  factory="org.apache.tomcat.jdbc.pool.DataSourceFactory"
                  uniqueResourceName="process-engine"
                  driverClassName="com.mysql.jdbc.Driver"
                  url="jdbc:mysql://${{RDS_HOSTNAME}}:${{RDS_PORT}}/${{RDS_DB_NAME}}?autoReconnect=true&amp;serverTimezone=UTC"
                  username="${{RDS_USERNAME}}"
                  password="${{RDS_PASSWORD}}"
                  maxActive="20"
                  minIdle="5" />
    </xsl:template>
</xsl:stylesheet>