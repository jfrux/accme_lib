module AccmeLib
  module Pars
    class Serializer
      include ActiveModel::Validations
      COUNTRIES = %w{AFG AGO AIA ALA ALB AND ARE ARG ARM ASM ATA ATF ATG AUS AUT AZE BDI BEL BEN BES BFA BGD BGR BHR BHS BIH BLM BLR BLZ BMU BOL BRA BRB BRN BTN BVT BWA CAF CAN CCK CHE CHL CHN CIV CMR COD COG COK COL COM CPV CRI CUB CUW CXR CYM CYP CZE DEU DJI DMA DNK DOM DZA ECU EGY ERI ESH ESP EST ETH FIN FJI FLK FRA FRO FSM GAB GBR GEO GGY GHA GIB GIN GLP GMB GNB GNQ GRC GRD GRL GTM GUF GUM GUY HKG HMD HND HRV HTI HUN IDN IMN IND IOT IRL IRN IRQ ISL ISR ITA JAM JEY JOR JPN KAZ KEN KGZ KHM KIR KNA KOR KWT LAO LBN LBR LBY LCA LIE LKA LSO LTU LUX LVA MAC MAF MAR MCO MDA MDG MDV MEX MHL MKD MLI MLT MMR MNE MNG MNP MOZ MRT MSR MTQ MUS MWI MYS MYT NAM NCL NER NFK NGA NIC NIU NLD NOR NPL NRU NZL OMN PAK PAN PCN PER PHL PLW PNG POL PRI PRK PRT PRY PSE PYF QAT REU ROU RUS RWA SAU SDN SEN SGP SGS SHN SJM SLB SLE SLV SMR SOM SPM SRB SSD STP SUR SVK SVN SWE SWZ SXM SYC SYR TCA TCD TGO THA TJK TKL TKM TLS TON TTO TUN TUR TUV TWN TZA UGA UKR UMI URY USA UZB VAT VCT VEN VGB VIR VNM VUT WLF WSM YEM ZAF ZMB ZWE}
      STATES = %w{AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY DC AS GU MP PR UM VI}
      ACTIVITY_TYPES = %w{ C CML EM IEM IL ISL JN LFT MR PI RSS TIW }
      @@max_supporters=0
      validate :check_accme_xor_provider_activity_id

      validates_presence_of :template,
                            :reporting_year,
                            :activity_title,
                            :activity_date,
                            :activity_type,
                            :hours_of_instruction,
                            :no_of_physicians,
                            :no_of_other_learners
      validates_inclusion_of :providership,
                              in: %w{ Direct Joint },
                              message: "Providership must be one of 'Direct' or 'Joint'"
      validates_presence_of :commercial_support_received

      validates :no_of_commercial_supporters, :presence => true, if: ->(obj){ obj.commercial_support_received? }
      validates :total_monetary_amount_received,
                presence: true,
                if: -> (obj) { obj.commercial_support_received? }
      validates_inclusion_of :inkind_durable,
                :inkind_space,
                :inkind_dispose,
                :inkind_animal,
                :inkind_human,
                in: [true, false],
                message: 'Required to be true or false',
                if: -> (obj) { obj.commercial_support_received? }

      validates_presence_of :city, if: -> (obj) { !!obj.activity_type && obj.activity_type.in?(%w{C RSS}) }, :message => "Shouldn't be blank since activity type is C or RSS"

      validates_inclusion_of :country,
                            in: COUNTRIES,
                            if: -> (obj) { !!obj.activity_type && obj.activity_type.in?(%w{C RSS}) },
                            message: "Country is required for activity type's C and RSS.\nMust be one of these: #{COUNTRIES}"
      validates_inclusion_of :state,
                            in: STATES,
                            if: -> (obj) { !!obj.activity_type && !!obj.country && (obj.country == 'USA') && obj.activity_type.in?(%w{C RSS}) },
                            message: "State is required for activity type's C / RSS and also when country is 'USA'\nMust be one of these: #{STATES}"

      validates_inclusion_of :activity_type,
                              in: ACTIVITY_TYPES,
                              message: "Must be one of 'C' 'CML' 'EM' 'IEM' 'IL' 'ISL' 'JN' 'LFT' 'MR' 'PI' 'RSS' 'TIW'"

      validates_inclusion_of  :designed_to_change_competence,
                              :changes_in_competence_evaluated,
                              :designed_to_change_performance,
                              :changes_in_performance_evaluated,
                              :designed_to_change_patient_outcomes,
                              :changes_in_patient_outcomes_evaluated,
                              in: [true, false],
                              message: "Required to be true or false"

      validates_numericality_of :no_of_credits_designated, allow_nil: true, allow_blank: true
      validates_numericality_of :hours_of_instruction, greater_than: 0
      validates_numericality_of :no_of_physicians, :no_of_other_learners
      validates_numericality_of :total_monetary_amount_received, greater_than:0, if: -> (obj) {
        (
        obj.commercial_support_received? &&
        !obj.inkind_durable &&
        !obj.inkind_space &&
        !obj.inkind_dispose &&
        !obj.inkind_animal &&
        !obj.inkind_human &&
        obj.inkind_other.blank?
        )
      },
      message: "This should be greater than 0 since no InKind support was found."

      validates_inclusion_of  :abms_acgme_patient_care_and_procedural_skills,
                              :abms_acgme_medical_knowledge,
                              :abms_acgme_practice_based_learning_and_improvement,
                              :abms_acgme_interpersonal_and_communication_skills,
                              :abms_acgme_professionalism,
                              :abms_acgme_systems_based_practice,
                              :institute_of_medicine_provide_patient_centered_care,
                              :institute_of_medicine_work_in_interdisciplinary_teams,
                              :institute_of_medicine_employ_evidence_based_practice,
                              :institute_of_medicine_apply_quality_improvement,
                              :institute_of_medicine_utilize_informatics,
                              :interprofessional_education_collaborative_values_ethics_for_interprofessional_practice,
                              :interprofessional_education_collaborative_roles_responsibilities,
                              :interprofessional_education_collaborative_interprofessional_communication,
                              :interprofessional_education_collaborative_teams_and_teamwork,
                              in: [true, false],
                              message: "Required to be true or false",
                              allow_nil: true,
                              allow_blank: true

      validates_format_of :template, with: /\ATemplate\ [A-Z]\z/i
      validates_numericality_of :accme_activity_id, allow_nil: true, allow_blank: true
      validates_numericality_of :provider_activity_id, allow_nil: true, allow_blank: true
      validates_numericality_of :reporting_year
      validates_length_of :reporting_year, maximum: 4


      # ACTIVITY TYPE
      # - C   => Course
      # - RSS => Regularly Scheduled Series
      # - IL  => Internet Live Course
      # - EM  => Enduring Material
      # - IEM => Internet Activity Enduring Material
      # - JN  => Journal-based CME
      # - MR  => Manuscript Review
      # - TIW => Test Item Writing
      # - CML => Committee Learning
      # - PI  => Performance Improvement
      # - ISL => Internet Searching and Learning
      # - LFT => Learning from Teaching
      ATTR_LABELS = {
        :template => "Template (DO NOT ALTER OR DELETE THIS COLUMN)",
        :accme_activity_id => "ACCME Activity ID",
        :provider_activity_id => "Provider Activity ID",
        :reporting_year => "Reporting Year",
        :activity_title => "Activity Title",
        :activity_date => "Activity Date",
        :city => "City",
        :state => "State",
        :country => "Country",
        :providership => "Providership",
        :activity_type => "Activity Type",
        :hours_of_instruction => "Hours of Instruction",
        :no_of_physicians => "# of Physicians",
        :no_of_other_learners => "# of Other Learners",
        :commercial_support_received => "Commercial Support Received?",
        :no_of_commercial_supporters => "# of Commercial Supporters",
        :total_monetary_amount_received => "Total Monetary Amount Received (Activity)",
        :inkind_durable => "In Kind Support Received - Durable equipment? (Activity)",
        :inkind_space => "In Kind Support Received - Facilities / Space?  (Activity)",
        :inkind_dispose => "In Kind Support Received - Disposable supplies (Non-biological)? (Activity)",
        :inkind_animal => "In Kind Support Received - Animal parts or tissue? (Activity)",
        :inkind_human => "In Kind Support Received - Human parts or tissue? (Activity)",
        :inkind_other => "In Kind Support Received - Other? (Activity)",
        :designed_to_change_competence => "Designed to change Competence?",
        :changes_in_competence_evaluated => "Changes in Competence evaluated?",
        :designed_to_change_performance => "Designed to change Performance?",
        :changes_in_performance_evaluated => "Changes in Performance evaluated?",
        :designed_to_change_patient_outcomes => "Designed to change Patient Outcomes?",
        :changes_in_patient_outcomes_evaluated => "Changes in Patient Outcomes evaluated?",
        :sub_category_case_based_discussion => "Sub-category: Case based discussion",
        :sub_category_lecture => "Sub-category: Lecture",
        :sub_category_panel => "Sub-category: Panel",
        :sub_category_simulation => "Sub-category: Simulation",
        :sub_category_skill_based_training => "Sub-category: Skill-based training",
        :sub_category_small_group_discussion => "Sub-category: Small group discussion",
        :sub_category_other => "Sub-category: Other",
        :joint_providers => "Joint Provider(s)",
        :no_of_credits_designated => "Number of AMA PRA Category 1 CreditsTM Designated",
        :description_of_content => "Description of Content",
        :advertising_exhibit_income => "Advertising & Exhibit Income (Activity)",
        :other_income => "Other Income (Activity)",
        :expenses => "Expenses (Activity)",
        :abms_acgme_patient_care_and_procedural_skills => "ABMS/ACGME - Patient Care and Procedural Skills",
        :abms_acgme_medical_knowledge => "ABMS/ACGME - Medical Knowledge",
        :abms_acgme_practice_based_learning_and_improvement => "ABMS/ACGME - Practice-based Learning and Improvement",
        :abms_acgme_interpersonal_and_communication_skills => "ABMS/ACGME - Interpersonal and Communication Skills",
        :abms_acgme_professionalism => "ABMS/ACGME - Professionalism",
        :abms_acgme_systems_based_practice => "ABMS/ACGME - Systems-based Practice",
        :institute_of_medicine_provide_patient_centered_care => "Institute of Medicine - Provide patient-centered care",
        :institute_of_medicine_work_in_interdisciplinary_teams => "Institute of Medicine - Work in interdisciplinary teams",
        :institute_of_medicine_employ_evidence_based_practice => "Institute of Medicine - Employ evidence-based practice",
        :institute_of_medicine_apply_quality_improvement => "Institute of Medicine - Apply quality improvement",
        :institute_of_medicine_utilize_informatics => "Institute of Medicine - Utilize informatics",
        :interprofessional_education_collaborative_values_ethics_for_interprofessional_practice => "Interprofessional Education Collaborative - Values/Ethics for Interprofessional Practice",
        :interprofessional_education_collaborative_roles_responsibilities => "Interprofessional Education Collaborative - Roles/Responsibilities",
        :interprofessional_education_collaborative_interprofessional_communication => "Interprofessional Education Collaborative - Interprofessional Communication",
        :interprofessional_education_collaborative_teams_and_teamwork => "Interprofessional Education Collaborative - Teams and Teamwork",
        :other_competencies_competencies_other_than_those_listed_were_addressed => "Other Competencies - Competencies other than those listed were addressed"
      }

      SUPPORT_SOURCE_LABELS = {
        :commercial_supporters_source => "Commercial Supporters Source",
        :monetary_amount_received => "Monetary Amount Received (from Commercial Support)",
        :inkind_durable => "In Kind Support Received - Durable equipment?",
        :inkind_space => "In Kind Support Received - Facilities / Space?",
        :inkind_dispose => "In Kind Support Received - Disposable supplies (Non-biological)?",
        :inkind_animal => "In Kind Support Received - Animal parts or tissue?",
        :inkind_human => "In Kind Support Received - Human parts or tissue?",
        :inkind_other => "In Kind Support Received - Other?"
      }

      attr_accessor :template,
                    :accme_activity_id,
                    :provider_activity_id,
                    :reporting_year,
                    :activity_title,
                    :activity_date,
                    :city,
                    :state,
                    :country,
                    :providership,
                    :activity_type,
                    :hours_of_instruction,
                    :no_of_physicians,
                    :no_of_other_learners,
                    :commercial_support_received,
                    :no_of_commercial_supporters,
                    :total_monetary_amount_received,
                    :inkind_durable,
                    :inkind_space,
                    :inkind_dispose,
                    :inkind_animal,
                    :inkind_human,
                    :inkind_other,
                    :designed_to_change_competence,
                    :changes_in_competence_evaluated,
                    :designed_to_change_performance,
                    :changes_in_performance_evaluated,
                    :designed_to_change_patient_outcomes,
                    :changes_in_patient_outcomes_evaluated,
                    :sub_category_case_based_discussion,
                    :sub_category_lecture,
                    :sub_category_panel,
                    :sub_category_simulation,
                    :sub_category_skill_based_training,
                    :sub_category_small_group_discussion,
                    :sub_category_other,
                    :joint_providers,
                    :no_of_credits_designated,
                    :description_of_content,
                    :advertising_exhibit_income,
                    :other_income,
                    :expenses,
                    :abms_acgme_patient_care_and_procedural_skills,
                    :abms_acgme_medical_knowledge,
                    :abms_acgme_practice_based_learning_and_improvement,
                    :abms_acgme_interpersonal_and_communication_skills,
                    :abms_acgme_professionalism,
                    :abms_acgme_systems_based_practice,
                    :institute_of_medicine_provide_patient_centered_care,
                    :institute_of_medicine_work_in_interdisciplinary_teams,
                    :institute_of_medicine_employ_evidence_based_practice,
                    :institute_of_medicine_apply_quality_improvement,
                    :institute_of_medicine_utilize_informatics,
                    :interprofessional_education_collaborative_values_ethics_for_interprofessional_practice,
                    :interprofessional_education_collaborative_roles_responsibilities,
                    :interprofessional_education_collaborative_interprofessional_communication,
                    :interprofessional_education_collaborative_teams_and_teamwork,
                    :other_competencies_competencies_other_than_those_listed_were_addressed,
                    :commercial_sources

      def initialize(args = Hash[])
        args.each do |k,v|
          instance_variable_set("@#{k}", v) unless v.nil?
        end
        @commercial_sources = args[:commercial_sources] || []
      end

      def headings
        columns = []
        columns << ATTR_LABELS[:template]
        columns << ATTR_LABELS[:accme_activity_id]
        columns << ATTR_LABELS[:provider_activity_id]
        columns << ATTR_LABELS[:reporting_year]
        columns << ATTR_LABELS[:activity_title]
        columns << ATTR_LABELS[:activity_date]
        columns << ATTR_LABELS[:city]
        columns << ATTR_LABELS[:state]
        columns << ATTR_LABELS[:country]
        columns << ATTR_LABELS[:providership]
        columns << ATTR_LABELS[:activity_type]
        columns << ATTR_LABELS[:hours_of_instruction]
        columns << ATTR_LABELS[:no_of_physicians]
        columns << ATTR_LABELS[:no_of_other_learners]
        columns << ATTR_LABELS[:commercial_support_received]

        if reporting_year == "2014"
          columns << ATTR_LABELS[:no_of_commercial_supporters]
          columns << ATTR_LABELS[:total_monetary_amount_received]
          columns << ATTR_LABELS[:inkind_durable]
          columns << ATTR_LABELS[:inkind_space]
          columns << ATTR_LABELS[:inkind_dispose]
          columns << ATTR_LABELS[:inkind_animal]
          columns << ATTR_LABELS[:inkind_human]
          columns << ATTR_LABELS[:inkind_other]
        end

        columns << ATTR_LABELS[:designed_to_change_competence]
        columns << ATTR_LABELS[:changes_in_competence_evaluated]
        columns << ATTR_LABELS[:designed_to_change_performance]
        columns << ATTR_LABELS[:changes_in_performance_evaluated]
        columns << ATTR_LABELS[:designed_to_change_patient_outcomes]
        columns << ATTR_LABELS[:changes_in_patient_outcomes_evaluated]
        columns << ATTR_LABELS[:sub_category_case_based_discussion]
        columns << ATTR_LABELS[:sub_category_lecture]
        columns << ATTR_LABELS[:sub_category_panel]
        columns << ATTR_LABELS[:sub_category_simulation]
        columns << ATTR_LABELS[:sub_category_skill_based_training]
        columns << ATTR_LABELS[:sub_category_small_group_discussion]
        columns << ATTR_LABELS[:sub_category_other]
        columns << ATTR_LABELS[:joint_providers]
        columns << ATTR_LABELS[:no_of_credits_designated]
        columns << ATTR_LABELS[:description_of_content]
        if reporting_year == "2014"
          columns << ATTR_LABELS[:advertising_exhibit_income]
          columns << ATTR_LABELS[:other_income]
          columns << ATTR_LABELS[:expenses]
        end
        columns << ATTR_LABELS[:abms_acgme_patient_care_and_procedural_skills]
        columns << ATTR_LABELS[:abms_acgme_medical_knowledge]
        columns << ATTR_LABELS[:abms_acgme_practice_based_learning_and_improvement]
        columns << ATTR_LABELS[:abms_acgme_interpersonal_and_communication_skills]
        columns << ATTR_LABELS[:abms_acgme_professionalism]
        columns << ATTR_LABELS[:abms_acgme_systems_based_practice]
        columns << ATTR_LABELS[:institute_of_medicine_provide_patient_centered_care]
        columns << ATTR_LABELS[:institute_of_medicine_work_in_interdisciplinary_teams]
        columns << ATTR_LABELS[:institute_of_medicine_employ_evidence_based_practice]
        columns << ATTR_LABELS[:institute_of_medicine_apply_quality_improvement]
        columns << ATTR_LABELS[:institute_of_medicine_utilize_informatics]
        columns << ATTR_LABELS[:interprofessional_education_collaborative_values_ethics_for_interprofessional_practice]
        columns << ATTR_LABELS[:interprofessional_education_collaborative_roles_responsibilities]
        columns << ATTR_LABELS[:interprofessional_education_collaborative_interprofessional_communication]
        columns << ATTR_LABELS[:interprofessional_education_collaborative_teams_and_teamwork]
        columns << ATTR_LABELS[:other_competencies_competencies_other_than_those_listed_were_addressed]

        1.upto(@@max_supporters) do |i|
          if i > 1
            intRankTxt = i.ordinalize
          else
            intRankTxt = ""
          end

          columns << "Commercial Support Source #{intRankTxt}"
          columns << "Monetary Amount Received (for Support Source) #{intRankTxt}"
          columns << "In Kind Support Received - Durable equipment? #{intRankTxt}"
          columns << "In Kind Support Received - Facilities / Space? #{intRankTxt}"
          columns << "In Kind Support Received - Disposable supplies (Non-biological)? #{intRankTxt}"
          columns << "In Kind Support Received - Animal parts or tissue? #{intRankTxt}"
          columns << "In Kind Support Received - Human parts or tissue? #{intRankTxt}"
          columns << "In Kind Support Received - Other? #{intRankTxt}"
        end

        col_count = 0
        columns.map! do |col|
          col_count += 1
          col = "#{col_count}. #{col}"
        end

        columns
      end

      def data
        columns = []
        columns << template
        columns << accme_activity_id
        columns << provider_activity_id
        columns << reporting_year
        columns << activity_title
        columns << activity_date.strftime("%m/%d/%Y")
        columns << city
        columns << state
        columns << country
        columns << providership
        columns << activity_type
        columns << hours_of_instruction
        columns << no_of_physicians
        columns << no_of_other_learners
        columns << pars_boolean(commercial_support_received?)

        if reporting_year == "2014"
          if commercial_support_received?
            columns << no_of_commercial_supporters
            columns << total_monetary_amount_received
            columns << pars_boolean(inkind_durable)
            columns << pars_boolean(inkind_space)
            columns << pars_boolean(inkind_dispose)
            columns << pars_boolean(inkind_animal)
            columns << pars_boolean(inkind_human)
            columns << inkind_other
          else
            columns << ""
            columns << ""
            columns << ""
            columns << ""
            columns << ""
            columns << ""
            columns << ""
            columns << ""
          end
        end

        columns << pars_boolean(designed_to_change_competence)
        columns << pars_boolean(changes_in_competence_evaluated)
        columns << pars_boolean(designed_to_change_performance)
        columns << pars_boolean(changes_in_performance_evaluated)
        columns << pars_boolean(designed_to_change_patient_outcomes)
        columns << pars_boolean(changes_in_patient_outcomes_evaluated)

        columns << sub_category_case_based_discussion
        columns << sub_category_lecture
        columns << sub_category_panel
        columns << sub_category_simulation
        columns << sub_category_skill_based_training
        columns << sub_category_small_group_discussion
        columns << sub_category_other
        columns << joint_providers
        columns << no_of_credits_designated
        columns << description_of_content
        if reporting_year == "2014"
          columns << advertising_exhibit_income
          columns << other_income
          columns << expenses
        end
        columns << pars_boolean(abms_acgme_patient_care_and_procedural_skills)
        columns << pars_boolean(abms_acgme_medical_knowledge)
        columns << pars_boolean(abms_acgme_practice_based_learning_and_improvement)
        columns << pars_boolean(abms_acgme_interpersonal_and_communication_skills)
        columns << pars_boolean(abms_acgme_professionalism)
        columns << pars_boolean(abms_acgme_systems_based_practice)
        columns << pars_boolean(institute_of_medicine_provide_patient_centered_care)
        columns << pars_boolean(institute_of_medicine_work_in_interdisciplinary_teams)
        columns << pars_boolean(institute_of_medicine_employ_evidence_based_practice)
        columns << pars_boolean(institute_of_medicine_apply_quality_improvement)
        columns << pars_boolean(institute_of_medicine_utilize_informatics)
        columns << pars_boolean(interprofessional_education_collaborative_values_ethics_for_interprofessional_practice)
        columns << pars_boolean(interprofessional_education_collaborative_roles_responsibilities)
        columns << pars_boolean(interprofessional_education_collaborative_interprofessional_communication)
        columns << pars_boolean(interprofessional_education_collaborative_teams_and_teamwork)

        columns << other_competencies_competencies_other_than_those_listed_were_addressed

        commercial_sources.each do |source|
          # puts source
          columns << source[:commercial_supporters_source]
          columns << source[:monetary_amount_received]
          columns << pars_boolean(source[:inkind_durable])
          columns << pars_boolean(source[:inkind_space])
          columns << pars_boolean(source[:inkind_dispose])
          columns << pars_boolean(source[:inkind_animal])
          columns << pars_boolean(source[:inkind_human])
          columns << source[:inkind_other]
        end

        columns
      end

      def city
        if (activity_type == 'C' || activity_type == 'RSS')
          @city
        else
          ""
        end
      end

      def state
        if (activity_type == 'C' || activity_type == 'RSS')
          @state
        else
          ""
        end
      end

      def country
        if (activity_type == 'C' || activity_type == 'RSS')
          @country
        else
          ""
        end
      end

      def attributes=(hash)
        hash.each do |key, value|
          send("#{key}=", value)
        end
      end

      def attributes
        instance_values
      end

      def template
        if @reporting_year == '2014'
          'Template C'
        elsif @reporting_year == '2015'
          'Template D'
        end
      end

      def commercial_support_received
        pars_boolean(commercial_support_received?)
      end

      def commercial_support_received?
        if @commercial_sources.any?
          true
        else
          false
        end
      end

      def calc_total_monetary_amount_received
        self.total_monetary_amount_received = 0
        @commercial_sources.each do |source|
          self.total_monetary_amount_received += source[:monetary_amount_received].to_f
        end

        # self.total_monetary_amount_received
      end

      def inkind_durable
        has_inkind = false
        @commercial_sources.each do |source|
          if source[:inkind_durable]
            has_inkind = true
            break
          else
            has_inkind = false
          end
        end
        has_inkind
      end

      def inkind_space
        has_inkind = false
        @commercial_sources.each do |source|
          if source[:inkind_space]
            has_inkind = true
            break
          else
            has_inkind = false
          end
        end
        has_inkind
      end

      def inkind_dispose
        has_inkind = false
        @commercial_sources.each do |source|
          if source[:inkind_dispose]
            has_inkind = true
            break
          else
            has_inkind = false
          end
        end
        has_inkind
      end

      def inkind_animal
        has_inkind = false
        @commercial_sources.each do |source|
          if source[:inkind_animal]
            has_inkind = true
            break
          else
            has_inkind = false
          end
        end
        has_inkind
      end

      def inkind_human
        has_inkind = false
        @commercial_sources.each do |source|
          if source[:inkind_human]
            has_inkind = true
            break
          else
            has_inkind = false
          end
        end
        has_inkind
      end

      # def inkind_other
      #   has_inkind = false
      #   @commercial_sources.each do |source|
      #     if source[:inkind_other]
      #       has_inkind = true
      #       break
      #     else
      #       has_inkind = false
      #     end
      #   end
      #   has_inkind
      # end

      def no_of_commercial_supporters
        @commercial_sources.length
      end

      # def set_max_supporters(max_supp)
      #   @@max_supporters = max_supp
      # end

      def max_supporters
        @@max_supporters
      end

      def add_commercial_source(args = Hash[])
        support = Hash[]
        args.each do |k,v|
          support[k]=v
        end

        @commercial_sources << support
        calc_total_monetary_amount_received
        if (@commercial_sources.length > @@max_supporters)
          @@max_supporters = @commercial_sources.length
        end
      end

      def pars_boolean(boolean)
        boolean ? 'Yes' : 'No'
      end

      def pars_number(number)
        ((number > 0) ? number : '').to_s
      end

      private
      def check_accme_xor_provider_activity_id
        if !(accme_activity_id.blank? ^ provider_activity_id.blank?)
          errors.add(:base, "Requires either an ACCME Activity ID or Provider Activity ID.")
        end
      end
    end
  end
end
