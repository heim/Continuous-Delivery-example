package no.bekk.bekkopen.cde.web.tags;

import no.bekk.bekkopen.cde.feature.Enabled;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.TagSupport;

import org.springframework.util.ReflectionUtils;

import static org.springframework.util.ReflectionUtils.findMethod;

/**
 * @author Eirik Wang - eirik.wang@bekk.no
 */
public class Feature extends TagSupport {

	private static final long serialVersionUID = 2935318125797185917L;
	
	private String name;
    private Enabled enabled;

    public String getName() {
        return name;
    }

    /**
     * @noinspection unchecked
     */
    public void setName(String feature) throws ClassNotFoundException {
        String[] features = feature.split("\\.");
        Class<?> clz = Class.forName("no.bekk.bekkopen.cde.feature.Feature$" + features[0]);
        enabled = (Enabled) ReflectionUtils.invokeMethod(findMethod(clz, "valueOf", String.class), null, features[1]);
        System.out.println(enabled.isEnabled());
    }

    public static void main(String[] args) throws ClassNotFoundException, JspException {
        Feature f = new Feature();
        f.setName("Course.Delete");
        System.out.println(f.doStartTag());
    }

    public Enabled getEnabled() {
        return enabled;
    }

    @Override
    public int doStartTag() throws JspException {
        return enabled.isEnabled() ? EVAL_BODY_INCLUDE : SKIP_BODY;
    }
}
