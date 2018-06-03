class ImageRecognition
  attr_reader :images

  def initialize(images)
    @images = images
  end

  def has_keeb_image?
    image_files = []
    vision = Google::Cloud::Vision.new
    keeb_image = false

    images.each do |image|
      is = image.split("/")
      image_name = "#{is[-2]}_#{is[-1]}"
      File.open(image_name, "wb") do |fo|
        fo.write open(image).read
      end
      image_files << image_name
      vision_image = vision.image(image_name)
      labels = vision_image.labels

      if labels.any? { |l| l.description =~ /keyboard/i }
        keeb_image = true
        break
      end
    end

    keeb_image
  ensure
    FileUtils.rm image_files, :force => true
  end
end
