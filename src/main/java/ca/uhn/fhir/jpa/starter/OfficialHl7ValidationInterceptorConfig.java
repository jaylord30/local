package ca.uhn.fhir.jpa.starter;

import ca.uhn.fhir.context.FhirContext;
import ca.uhn.fhir.interceptor.api.IInterceptorService;
import ca.uhn.fhir.jpa.interceptor.validation.IRepositoryValidatingRule;
import ca.uhn.fhir.jpa.interceptor.validation.RepositoryValidatingInterceptor;
import ca.uhn.fhir.jpa.interceptor.validation.RepositoryValidatingRuleBuilder;
import ca.uhn.fhir.validation.ResultSeverityEnum;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OfficialHl7ValidationInterceptorConfig {

    private static final Logger ourLog =
            LoggerFactory.getLogger(OfficialHl7ValidationInterceptorConfig.class);

    private static final String PHCORE_PATIENT_PROFILE =
            "https://fhir.doh.gov.ph/phcore/StructureDefinition/ph-core-patient";

    private final FhirContext fhirContext;
    private final IInterceptorService interceptorService;
    private final RepositoryValidatingRuleBuilder ruleBuilder;

    public OfficialHl7ValidationInterceptorConfig(
            FhirContext fhirContext,
            IInterceptorService interceptorService,
            RepositoryValidatingRuleBuilder ruleBuilder
    ) {
        this.fhirContext = fhirContext;
        this.interceptorService = interceptorService;
        this.ruleBuilder = ruleBuilder;
    }

    @PostConstruct
    public void registerOfficialHl7Validator() {

        /*
         * Rule 1:
         * Patient must declare PH Core Patient profile in meta.profile.
         */
        ruleBuilder
                .forResourcesOfType("Patient")
                .requireAtLeastProfile(PHCORE_PATIENT_PROFILE)
                .and()
                .requireValidationToDeclaredProfiles()
                .errorOnUnknownProfiles()
                .rejectOnSeverity(ResultSeverityEnum.ERROR);

        /*
         * Optional:
         * If you want ServiceRequest, Observation, Encounter, etc.
         * to validate against whatever profile they declare in meta.profile,
         * add rules like this:
         */
        ruleBuilder
                .forResourcesOfType("ServiceRequest")
                .requireValidationToDeclaredProfiles()
                .errorOnUnknownProfiles()
                .rejectOnSeverity(ResultSeverityEnum.ERROR);

        ruleBuilder
                .forResourcesOfType("Observation")
                .requireValidationToDeclaredProfiles()
                .errorOnUnknownProfiles()
                .rejectOnSeverity(ResultSeverityEnum.ERROR);

        List<IRepositoryValidatingRule> rules = ruleBuilder.build();

        RepositoryValidatingInterceptor interceptor =
                new RepositoryValidatingInterceptor(fhirContext, rules);

        interceptorService.registerInterceptor(interceptor);

        ourLog.info("Official HL7/FHIR repository validation interceptor registered");
    }
}