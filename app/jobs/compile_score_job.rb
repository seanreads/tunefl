require 'erb'

class CompileScoreJob
  
  @queue = :compile_score_job
  
  def self.perform(id)
    score = Score.find(id)
    
    tmpdir = Rails.root.join('tmp', 'jobs', 'CompileScoreJob')
    
    files = {
      :lilypond     => tmpdir.join("#{id}.ly"),
      :midi         => tmpdir.join("#{id}.midi"),
      :png          => tmpdir.join("#{id}.png"),
      :preview_eps  => tmpdir.join("#{id}.preview.eps"),
      :preview_png  => tmpdir.join("#{id}.preview.png"),
    }
    
    begin
      CompileScoreJob::generate_lilypond(score, files)
      
      CompileScoreJob::compile_lilypond(score, files)
    rescue Exception => e
      score.usable = false
      
      score.save
      
      raise e
    ensure
      files.each { |k, v| FileUtils.rm(v) if File.exists?(v) }
    end
    
    score.usable = true
    
    score.save
  end
  
  def self.generate_lilypond(score, files)
    lilypond_data = ERB.new(File.read(
      Rails.root.join('app', 'views', 'erb', 'lilypond.ly.erb')
    )).result(binding)
    
    File.write(files[:lilypond], lilypond_data)
    
    score.lilypond = File.open(files[:lilypond])
    
    score.save
  end
  
  def self.compile_lilypond(score, files)
    `lilypond -dsafe -dresolution=150 -dpreview --png --output #{File.dirname(files[:lilypond])} #{files[:lilypond]}`
    
    score.preview = File.open(files[:preview_png])
    
    score.midi = File.open(files[:midi])
    
    score.save
  end
  
end

