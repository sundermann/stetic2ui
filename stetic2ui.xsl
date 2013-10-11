<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="3.0">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    
    <xsl:variable name="mappings">
        <mappings>
            <mapping from="LabelProp" to="label" />
        </mappings>
    </xsl:variable>
    
    <xsl:template match="text()" mode="#all" />
    
    <xsl:template match="stetic-interface">
        <xsl:apply-templates />
    </xsl:template>
    
    <xsl:template match="widget[@design-size]">
        
        <xsl:variable name="id">
            <xsl:call-template name="substring-after-last">
                <xsl:with-param name="string1" select="@id" />
                <xsl:with-param name="string2">.</xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:result-document encoding="utf8" href="{$id}.ui">
            <interface>
                <xsl:comment> interface-requires gtk+ 3.0 </xsl:comment>
                                
                <object class="{translate (@class, '.', '')}" id="{$id}">
                    
                    <!-- GtkBin is not instantiable so switch to GtkBox -->
                    <xsl:if test="@class='Gtk.Bin'">
                        <xsl:attribute name="class">GtkBox</xsl:attribute>
                    </xsl:if>
                    
                    <!-- GtkComboBoxEntry is now Combobox -->
                    <xsl:if test="@class='Gtk.ComboBoxEntry'">
                        <xsl:attribute name="class">GtkComboBox</xsl:attribute>
                        <property name="has_entry">True</property>
                    </xsl:if>
                    
                    <!-- hack for Checkbutton which has no default values sometimes -->
                    <xsl:if test="@class='Gtk.CheckButton' and not (property[@name='xalign'])">
                        <property name="xalign">0</property>
                    </xsl:if>
                    
                    <xsl:apply-templates />
                </object>
                
            </interface>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="widget[not(@design-size)]">
        
        <object class="{translate (@class, '.', '')}" id="{@id}">
            
            <!-- GtkBin is not instantiable so switch to GtkBox -->
            <xsl:if test="@class='Gtk.Bin'">
                <xsl:attribute name="class">GtkBox</xsl:attribute>
            </xsl:if>
            
            <!-- GtkComboBoxEntry is now Combobox -->
            <xsl:if test="@class='Gtk.ComboBoxEntry'">
                <xsl:attribute name="class">GtkComboBox</xsl:attribute>
                <property name="has_entry">True</property>
            </xsl:if>
            
            <!-- hack for Checkbutton which has no default values sometimes -->
            <xsl:if test="@class='Gtk.CheckButton' and not (property[@name='xalign'])">
                <property name="xalign">0</property>
            </xsl:if>
            
            <!-- hack for VBox which is now Box with vertical property -->
            <xsl:if test="@class='Gtk.VBox'">
                <xsl:attribute name="class">GtkBox</xsl:attribute>
                <property name="orientation">vertical</property>
            </xsl:if>
            
            <xsl:apply-templates />
        </object>
    </xsl:template>
    
    <xsl:template match="property">
        <property>
            <xsl:attribute name="name">
                <xsl:call-template name="cnamize">
                    <xsl:with-param name="text" select="@name" />
                </xsl:call-template>
            </xsl:attribute>
            <xsl:if test="@translatable">
                <xsl:attribute name="translatable">
                    <xsl:value-of select="@translatable"/>
                </xsl:attribute>
            </xsl:if>

            <xsl:value-of select="current()"/>
        </property>
    </xsl:template>
    
    <xsl:template match="packing">
        <packing>
            <xsl:apply-templates/>
        </packing>
    </xsl:template>
    
    <xsl:template match="signal">
        <signal name="{@name}" handler="{@handler}" swapped="no"></signal>
    </xsl:template>
    
    <xsl:template match="child">
        <child>
            <xsl:if test="@internal-child">
                <xsl:variable name="internal-child">
                    <xsl:choose>
                        <xsl:when test="@internal-child='ActionArea'">action_area</xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="translate (@internal-child,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:attribute name="internal-child"><xsl:value-of select="$internal-child"/></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates />
        </child>
    </xsl:template>
    
    <xsl:template name="cnamize">
        <xsl:param name="text" />
        
        <xsl:choose>
            <xsl:when test="$mappings/mappings/mapping[@from=$text]">
                <xsl:value-of select="$mappings/mappings/mapping[@from=$text]/@to"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="tmp">
                    <xsl:value-of select="substring($text, 2)"/>
                </xsl:variable>
                
                <xsl:value-of select="translate(substring($text,1,1),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" />
                <xsl:call-template name="cnamize-intern">
                    <xsl:with-param name="text" select="$tmp" />
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="cnamize-intern">
        <xsl:param name="text" />
        <xsl:param name="index" select="1" />
        
        <xsl:if test="string-length($text) &gt;= $index">         
            <xsl:variable name="letter">
                <xsl:value-of select="substring($text, $index, 1)"/>
            </xsl:variable>
            
            <xsl:choose>
                <xsl:when test="$letter='A'">_a</xsl:when>
                <xsl:when test="$letter='B'">_b</xsl:when>
                <xsl:when test="$letter='C'">_c</xsl:when>
                <xsl:when test="$letter='D'">_d</xsl:when>
                <xsl:when test="$letter='E'">_e</xsl:when>
                <xsl:when test="$letter='F'">_f</xsl:when>
                <xsl:when test="$letter='G'">_g</xsl:when>
                <xsl:when test="$letter='H'">_h</xsl:when>
                <xsl:when test="$letter='I'">_i</xsl:when>
                <xsl:when test="$letter='J'">_j</xsl:when>
                <xsl:when test="$letter='K'">_k</xsl:when>
                <xsl:when test="$letter='L'">_l</xsl:when>
                <xsl:when test="$letter='M'">_m</xsl:when>
                <xsl:when test="$letter='N'">_n</xsl:when>
                <xsl:when test="$letter='O'">_o</xsl:when>
                <xsl:when test="$letter='P'">_p</xsl:when>
                <xsl:when test="$letter='Q'">_q</xsl:when>
                <xsl:when test="$letter='R'">_r</xsl:when>
                <xsl:when test="$letter='S'">_s</xsl:when>
                <xsl:when test="$letter='T'">_t</xsl:when>
                <xsl:when test="$letter='U'">_u</xsl:when>
                <xsl:when test="$letter='V'">_v</xsl:when>
                <xsl:when test="$letter='W'">_w</xsl:when>
                <xsl:when test="$letter='X'">_x</xsl:when>
                <xsl:when test="$letter='Y'">_y</xsl:when>
                <xsl:when test="$letter='Z'">_z</xsl:when>
                <xsl:otherwise><xsl:value-of select="$letter"/></xsl:otherwise>
            </xsl:choose>
            
            <xsl:call-template name="cnamize-intern">
                <xsl:with-param name="text" select="$text" />
                <xsl:with-param name="index" select="$index+1" />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="substring-after-last">
        <xsl:param name="string1" select="''" />
        <xsl:param name="string2" select="''" />
        
        <xsl:if test="$string1 != '' and $string2 != ''">
            <xsl:variable name="head" select="substring-before($string1, $string2)" />
            <xsl:variable name="tail" select="substring-after($string1, $string2)" />
            
            <xsl:choose>
                <xsl:when test="contains($tail, $string2)">
                    <xsl:call-template name="substring-after-last">
                        <xsl:with-param name="string1" select="$tail" />
                        <xsl:with-param name="string2" select="$string2" />
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$tail"></xsl:value-of>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>