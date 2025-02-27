<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>

<h1><fmt:message key="course.form.title"/></h1>

<c:if test="${not empty statusMessageKey}">
    <p><fmt:message key="${statusMessageKey}"/></p>
</c:if>

<c:url var="url" value="/course/form.html"/>
<form:form action="${url}" commandName="course">
    <form:hidden path="id"/>

    <fieldset>
        <div class="form-row">
            <label for="name"><fmt:message key="course.form.name"/>:</label>
            <span class="input"><form:input path="name"/></span>
        </div>
        <div class="form-row">
            <label for="location"><fmt:message key="course.form.location"/>:</label>
            <span class="input"><form:input path="location"/></span>
        </div>
        <div class="form-row">
            <label for="date"><fmt:message key="course.form.date"/>:</label>
            <span class="input"><form:input path="date"/></span>
        </div>
        <div class="form-buttons">
            <div class="button"><input name="submit" type="submit" value="<fmt:message key="button.save"/>"/></div>
        </div>
    </fieldset>

</form:form>