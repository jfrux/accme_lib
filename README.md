# ACCME Lib
This is a Ruby gem that currently has a narrow applicable use but in its current form it aids to serialize and validate ACCME PARS data and prepare it to be generated into an Excel file.

This is extremely alpha and should be used at your own risk.  
It's a work in progress and hasn't been tested thoroughly.
Plans are to build on it as we find uses within our existing CME management system at the University of Cincinnati.

## Issues
It is important to note that this library is not written, maintained, or supported by the ACCME.
Please do not email them with questions relating to the usage or implementation of this library.

Please post all issues to GitHub issues at https://github.com/joshuairl/accme_lib/issues

## Example Usage
### Helpful rules built in!
There are simple but helpful rules built in to help you produce properly formatted data for importing into PARS.
Below is an example of how simply assigning the `reporting_year` property changes the `template` property to the proper template.
It also reflects the columns that are output from the `#data` and `#headings` methods which you will see further down the page.

```ruby
pars = AccmeLib::Pars::Serializer.new :reporting_year => '2014' # => #<AccmeLib::Pars::Serializer:0x007fb2fef52590 @commercial_sources=[], @reporting_year="2014">
pars.template # => "Template C"

pars.reporting_year = '2015'
pars.template # => "Template D"
```

### Validations
We've been working to implement sensible validations to help aide in importing valid records into the ACCME PARS system as seamless as possible with minimal hiccups.

It also allows us to produce conditional formatting of rows in our excel templates when we are reviewing our records prior to importing.

```ruby
pars.activity_type = 'C'
pars.country = 'USA'

pars.valid? # => false
pars.errors.messages
# => {
# :base=>["Record requires either an ACCME Activity ID or Provider Activity ID."],
# :activity_title=>["ActivityTitle cannot be blank."],
# :activity_date=>["ActivityDate must be a valid date object."],
# :providership=>["Providership must be one of 'Direct' or 'Joint'"],
# :hours_of_instruction=>["HoursOfInstruction must be a valid number."],
# :no_of_physicians=>["NoOfPhysicians cannot be blank and must be a valid number."],
# :no_of_other_learners=>["NoOfOtherLearners cannot be blank and must be a valid number."],
# :city=>["City is required for activity type's C / RSS"],
# :state=>["State is required for activity type's C / RSS and also when country is 'USA'\nMust be one of these: [\"AL\", \"AK\", \"AZ\", \"AR\", \"CA\", \"CO\", \"CT\", \"DE\", \"FL\", \"GA\", \"HI\", \"ID\", \"IL\", \"IN\", \"IA\", \"KS\", \"KY\", \"LA\", \"ME\", \"MD\", \"MA\", \"MI\", \"MN\", \"MS\", \"MO\", \"MT\", \"NE\", \"NV\", \"NH\", \"NJ\", \"NM\", \"NY\", \"NC\", \"ND\", \"OH\", \"OK\", \"OR\", \"PA\", \"RI\", \"SC\", \"SD\", \"TN\", \"TX\", \"UT\", \"VT\", \"VA\", \"WA\", \"WV\", \"WI\", \"WY\", \"DC\", \"AS\", \"GU\", \"MP\", \"PR\", \"UM\", \"VI\"]"],
# :designed_to_change_competence=>["Required to be true or false"],
# :changes_in_competence_evaluated=>["Required to be true or false"],
# :designed_to_change_performance=>["Required to be true or false"],
# :changes_in_performance_evaluated=>["Required to be true or false"],
# :designed_to_change_patient_outcomes=>["Required to be true or false"],
# :changes_in_patient_outcomes_evaluated=>["Required to be true or false"],
# ...
```

### Adding and totaling commercial support sources
There is an array object that maintains support sources as well.
`AccmeLib::Pars::Serializer#add_commercial_source`
Assuming you have an ActiveModel class of "Activity"...

```ruby
pars = AccmeLib::Pars::Serializer.new :reporting_year => '2014' # => #<AccmeLib::Pars::Serializer:0x007fb2fef52590 @commercial_sources=[], @reporting_year="2014">

my_activity = Activity.find(12345)
# => #<Activity id: 12345, parentactivityid: nil, activity_type_id: 1, activity_subtype_id: 2, title: "My Example Activity", description: "A great example activity", startdate: "2014-01-01 00:00:00", enddate: "2014-01-01 00:00:00", locationid: 1231, location: "Center for Clinical and Translational Science and ..." ...>

commercial_sources = my_activity.commercial_sources
#=> [#<ActivitySupport id: 5465456, amount: 324705.0, name: 'Pfizer'>]

if !!commercial_sources
  commercial_sources.each do |source|
    pars.add_commercial_source :commercial_supporters_source => source.name,
      :monetary_amount_received => source.amount,
      :inkind_durable => source.inkind_durable?,
      :inkind_space => source.inkind_space?,
      :inkind_dispose => source.inkind_dispose?,
      :inkind_animal => source.inkind_animal?,
      :inkind_human => source.inkind_human?,
      :inkind_other => source.inkind_other
  end
end

pars.no_of_commercial_supporters
# => 1

pars.total_monetary_amount_received
# => 324705.0
```

### Retrieving Formatted Column Values
`AccmeLib::Pars::Serializer#data` serializes and formats the data for compatibility with the PARS import template for the provided reporting year / template specification.

```ruby
pars.activity_date = Date.parse('31/1/2014')
#=> Fri, 31 Jan 2014
pars.data
# => ["Template C",
#  nil,
#  nil,
#  "2014",
#  nil,
#  "01/31/2014",
#  nil,
#  nil,
#  "USA",
#  nil,
#  "C",
#  nil,
#  nil,
#  nil,
#  "No",
#  "",
#  "",
#  "",
#  "",
#  "",
#  "",
#  "",
#  "",
#  "No",
#  "No",
#  "No",
#  "No",
#  "No",
#  "No",
#  nil,
#  nil,
#  nil,
#  nil,
#  nil,
#  nil,
#  nil,
#  nil,
#  nil,
#  nil,
#  nil,
#  nil,
#  nil,
#  "No",
#  "No",
#  "No",
#  "No",
#  "No",
#  "No",
#  "No",
#  "No",
#  "No",
#  "No",
#  "No",
#  "No",
#  "No",
#  "No",
#  "No",
#  nil]
```

### Retrieving Template Headings
`AccmeLib::Pars::Serializer#headings` returns an array of headings for the given template / reporting year if you desire to generate a nice populated excel template using the `axlsx` gem or something similar.

```ruby
pars.headings
=> ["1. Template (DO NOT ALTER OR DELETE THIS COLUMN)",
 "2. ACCME Activity ID",
 "3. Provider Activity ID",
 "4. Reporting Year",
 "5. Activity Title",
 "6. Activity Date",
 "7. City",
 "8. State",
 "9. Country",
 "10. Providership",
 "11. Activity Type",
 "12. Hours of Instruction",
 "13. # of Physicians",
 "14. # of Other Learners",
 "15. Commercial Support Received?",
 "16. # of Commercial Supporters",
 "17. Total Monetary Amount Received (Activity)",
 "18. In Kind Support Received - Durable equipment? (Activity)",
 "19. In Kind Support Received - Facilities / Space?  (Activity)",
 "20. In Kind Support Received - Disposable supplies (Non-biological)? (Activity)",
 "21. In Kind Support Received - Animal parts or tissue? (Activity)",
 "22. In Kind Support Received - Human parts or tissue? (Activity)",
 "23. In Kind Support Received - Other? (Activity)",
 "24. Designed to change Competence?",
 "25. Changes in Competence evaluated?",
 "26. Designed to change Performance?",
 "27. Changes in Performance evaluated?",
 "28. Designed to change Patient Outcomes?",
 "29. Changes in Patient Outcomes evaluated?",
 "30. Sub-category: Case based discussion",
 "31. Sub-category: Lecture",
 "32. Sub-category: Panel",
 "33. Sub-category: Simulation",
 "34. Sub-category: Skill-based training",
 "35. Sub-category: Small group discussion",
 "36. Sub-category: Other",
 "37. Joint Provider(s)",
 "38. Number of AMA PRA Category 1 CreditsTM Designated",
 "39. Description of Content",
 "40. Advertising & Exhibit Income (Activity)",
 "41. Other Income (Activity)",
 "42. Expenses (Activity)",
 "43. ABMS/ACGME - Patient Care and Procedural Skills",
 "44. ABMS/ACGME - Medical Knowledge",
 "45. ABMS/ACGME - Practice-based Learning and Improvement",
 "46. ABMS/ACGME - Interpersonal and Communication Skills",
 "47. ABMS/ACGME - Professionalism",
 "48. ABMS/ACGME - Systems-based Practice",
 "49. Institute of Medicine - Provide patient-centered care",
 "50. Institute of Medicine - Work in interdisciplinary teams",
 "51. Institute of Medicine - Employ evidence-based practice",
 "52. Institute of Medicine - Apply quality improvement",
 "53. Institute of Medicine - Utilize informatics",
 "54. Interprofessional Education Collaborative - Values/Ethics for Interprofessional Practice",
 "55. Interprofessional Education Collaborative - Roles/Responsibilities",
 "56. Interprofessional Education Collaborative - Interprofessional Communication",
 "57. Interprofessional Education Collaborative - Teams and Teamwork",
 "58. Other Competencies - Competencies other than those listed were addressed"]
```


This project uses MIT-LICENSE.
