class VolumeCalculator
  RATIOS = {
    "1:2:4" => { cement: 1, sand: 2, gravel: 4 },
    "1:3:6" => { cement: 1, sand: 3, gravel: 6 },
    "1:1.5:3" => { cement: 1, sand: 1.5, gravel: 3 }
  }.freeze

  CEMENT_PER_CUBIC_METER = 7.4

  attr_reader :length, :width, :height, :ratio

  def initialize(params)
    @length = params[:length].to_f
    @width = params[:width].to_f
    @height = params[:height].to_f
    @ratio = params[:ratio]
  end

  def calculate
    vol = length * width * height
    total_parts = RATIOS[ratio].values.sum
    ratio_data = RATIOS[ratio]

    {
      volume: vol,
      materials: {
        cement_bags: (vol * ratio_data[:cement] / total_parts * CEMENT_PER_CUBIC_METER).round,
        sand: vol * ratio_data[:sand] / total_parts,
        gravel: vol * ratio_data[:gravel] / total_parts
      }
    }
  end
end
