module ApplicationHelper
    # Return string representation of time in different time zone
    def tz_convert(timeobj,tz,format='%Y-%m-%d %I:%M%p') 
        return TZInfo::Timezone.get(tz).utc_to_local(timeobj).strftime(format)
    end

    def options_for_status(index=nil)
        codes=[
            ['Submitted',0],
            ['In Review',1],
            ['Accepted',2],
            ['Rejected',3]
        ]
        return codes[index][0] if index
        return codes
    end
   
 #Translate a boolean value into its string equivalent
 def bool_to_string(b_value)
    if b_value == nil
        'Pending'
    elsif b_value == False
        'No'
    elsif b_value == True
        'Yes'
    end
  end

  # Create form that if clicked will delete this record
  def delete_tag(title,f)
      return content_tag( :button,:name=>f.object_name+'_destroy', :value=>'1', :type=>'submit' )
  end                     

  def hour_options()
    result = [
        '12am',
        '1am',
        '2am',
        '3am',
        '4am',
        '5am',
        '6am',
        '7am',
        '8am',
        '9am',
        '10am',
        '11am',
        '12pm',
        '1pm',
        '2pm',
        '3pm',
        '4pm',
        '5pm',
        '6pm',
        '7pm',
        '8pm',
        '9pm',
        '10pm',
        '11pm'
    ]
  end

  def funding_options()
    options = [
          ['N/A',[
            'None of these - Describe below',
            'Department Funding - Org. 63601',
            'Bridge Funding']
          ],
          ['Bailey', [
          'Meaningful Use & Treatment of Smoking GFAMP0160B'],
          ],
          ['Biagioli', [
          'BSS Medical Education Curriculum GFAMP0119D',
          'Putting Stewardship into Medical Education and Training (ABIM Fdn) GFAMP0169A']
          ],
          ['Carney', [
          'M-Path GFAMP0110E',
          'BSS Medical Education Curriculum/Supplement for Evaluation GFAMP0119D1']
          ],
          ['Carney/Eiff', [
          'FM LOT Pilot Evaluation GFAMP0134B'],
          ],
          ['Cohen',[
          'TEAM-UP GFAMP0131C',
          'SPREAD-NET GFAMP0149B',
          'ESCALATES GFAMP0161A',
          'ESCALATES GFAMP0161A1 Emrg Med',
          'ESCALATES GFAMP0161A2 Impact fees',
          'ESCALATES GFAMP0161A3 Travel',
          'CLINCH-IT GFAMP0162A',
          'Optimizing display of blood pressure data to support clinical decision making GFAMP0172A',
          'A Pharmacy Prescription Drug Monitoring Program Toolkit to Improve Opioid Safety GFAMP0174A']
          ],
          ['Davis', [
          'Disparities in CRC Screening GFAMP0173A'],
          ],
          ['DeVoe',[
          'IoM Puffer Fellowship GFAMP0123A',
          'CATCH-UP GFAMP0143B',
          'eCHANGE AHRQ GFAMP0166A',
          'eCHANGE AHRQ GFAMP0166A1 PHPM',
          'eCHANGE AHRQ GFAMP0166A Emrg Med',
          'PACE  GFAMP0167A',
          'PREVENT-D: CDCP GFAMP0168A',
          'PREVENT-D: NIDDK GFAMP0168A1',
	  'ACCESS: NCI GFAMP0175A']
          ],
          ['Deyo',[
          'RELIEF GFAMP0108F',
          'Use of Prescription Monitoring PDMP GFAMP0113ESD',
          'Supplement to Use of Prescription Monitoring GFAMP0113E1SD',
          'LESSER GFAMP0136C',
          'LIRE GFAMP0142C',
          'Collaborative Care for Chronic Pain in Primary Care GFAMP0144B',
          'Understanding Non-response in Spine Fusion Surgery (UW/NIH NIAMS) GFAMP0170A',
          'LESSER GFAMP0136C']
          ],
          ['Eiff',[
          'PACER (ABFM) GFAMP0164A']
          ],
          ['Eiff/Carney',[
          'PACER (Macy Fdn) GFAMP0165A']
          ],
          ['Fields',[
          'DATA Initiative GFAMP0111ESD']
          ],
          ['Flynn',[
          'Clinical Innovators Program GFAMP0148A']
          ],
          ['Heintzman',[
          'Primary Care Medical Home & Preventive Service Use GFAMP0133C']
          ],
          ['Huguet',[
	  'ADVANCE GFAMP0147B',
          'Economic Contraction on Alcohol & Alcoholism GFAMP0159B']
          ],
          ['Marino',[
          'Evaluating cardiometabolic and sleep health benefits of a workplace intervention GFAMP0163A']
          ],
          ['Muench', [
          'Understanding Disparities GFAMP0126D',
          'SBIRT Training GFAMP0151B']
          ],
          ['Pillar',[
          'STOP Colon Cancer GFAMP0146A']
          ],
          ['Risser',[
          'RHEDI GFAMP0062H']
          ],
          ['Steiner',[
          'Improving empiric therapy in ambulatory care GFAMP0156B']
          ],
          ['Teuber', [
          'OHSU Richmond CHC GFAMP0145B',
          'OHSU Richmond CHC GFAMP0145B1',
          'OHSU Richmond CHC GFAMP0145B2',
          'OHSU Richmond CHC GFAMP0145B4']
          ],
    ]
    return options
  end

  def request_type_icon request_type
    request_types = {
        'icon-request-leave'=> 'rural18_32x28.png',
        'icon-request-travel'=> 'air6_32x28.png'
    }
    image_tag(request_types[request_type], :class=>'icon-request')
  end

  def flash_helper
      #return ''
      f_names = [:alert,:notice, :warning, :message, :error]
      fl = '' 
    for name in f_names
        if flash[name]
          fl << content_tag( :div, flash[name].html_safe, :class=>"flash_#{name}" )
        end
      #flash[name] = nil;
    end
    return raw fl
  end

  def boolean_to_words(value)
    value.present? ? "Yes" : "No"
  end

  def active_link_to name, path, opts={}
    opts[:class] = opts[:class].to_s + ' active' if request.path == path
    link_to name, path, opts
  end

end

