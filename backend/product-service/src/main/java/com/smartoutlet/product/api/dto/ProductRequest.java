package com.smartoutlet.product.api.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Product creation and update request")
public class ProductRequest {
    
    @Schema(description = "Product name", example = "Premium Coffee Beans")
    @NotBlank(message = "Product name is required")
    @Size(max = 200, message = "Product name cannot exceed 200 characters")
    private String name;
    
    @Schema(description = "Product description", example = "High-quality Arabica coffee beans sourced from Colombia")
    private String description;
    
    @Schema(description = "Stock Keeping Unit", example = "COFFEE-001")
    @NotBlank(message = "SKU is required")
    @Size(max = 50, message = "SKU cannot exceed 50 characters")
    private String sku;
    
    @Schema(description = "Barcode", example = "8901234567890")
    private String barcode;
    
    @Schema(description = "Selling price", example = "15.99")
    @NotNull(message = "Price is required")
    @DecimalMin(value = "0.0", inclusive = false, message = "Price must be greater than 0")
    private BigDecimal price;
    
    @Schema(description = "Cost price", example = "10.50")
    private BigDecimal costPrice;
    
    @Schema(description = "Current stock quantity", example = "100")
    @NotNull(message = "Stock quantity is required")
    @Min(value = 0, message = "Stock quantity cannot be negative")
    private Integer stockQuantity = 0;
    
    @Schema(description = "Minimum stock level for alerts", example = "20")
    private Integer minStockLevel = 5;
    
    @Schema(description = "Maximum stock level capacity", example = "500")
    private Integer maxStockLevel = 1000;
    
    @Schema(description = "Category ID", example = "1")
    private Long categoryId;
    
    @Schema(description = "Unit of measure", example = "PIECE", allowableValues = {"PIECE", "KG", "LITER", "METER"})
    private String unitOfMeasure = "PIECE";
    
    @Schema(description = "Product weight", example = "0.5")
    private BigDecimal weight;
    
    @Schema(description = "Product dimensions (LxWxH)", example = "10x5x2")
    private String dimensions;
    
    @Schema(description = "Brand name", example = "Colombian Harvest")
    private String brand;
    
    @Schema(description = "Supplier name", example = "Global Coffee Imports")
    private String supplier;
    
    @Schema(description = "Product active status", example = "true")
    private Boolean isActive = true;
    
    @Schema(description = "Is product taxable", example = "true")
    private Boolean isTaxable = true;
    
    @Schema(description = "Tax rate percentage", example = "7.5")
    private BigDecimal taxRate = BigDecimal.ZERO;
    
    @Schema(description = "Product image URL", example = "https://storage.smartoutlet.com/products/coffee-beans.jpg")
    private String imageUrl;
    
    @Schema(description = "Product tags (comma separated)", example = "coffee,beans,premium,organic")
    private String tags;
}